import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:showings/widgets/season_button.dart';
import 'package:showings/widgets/place_panel.dart';
import 'package:showings/screens/travel_course_page.dart';
import 'package:showings/settings/thema.dart'; // dayMapStyle / nightMapStyle (JSON 문자열)
import '../settings/theme_service.dart';      // ThemeService, ThemeDetail, ThemeDetailApi

class CourseTab extends StatefulWidget {
  const CourseTab({super.key});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  GoogleMapController? mapController;
  final PanelController _panelController = PanelController();

  // 맵/마커
  final LatLng _center = const LatLng(36.5, 127.8);
  Set<Marker> activeMarkers = {};
  Marker? selectedMarker;

  // 패널/상세
  bool isPanelOpen = false;
  bool _panelMostlyOpen = false;          // 패널 열림여부(임계치 기반)
  ThemeDetail? _detail;
  bool _loadingDetail = false;
  int _detailReqSeq = 0;

  // 필터 상태
  bool isDay = true;
  bool isSpring = false;
  bool isSummer = false;
  bool isFall = false;
  bool isWinter = false;

  // 맵 제스처
  bool _mapGesturesEnabled = true;

  // 요청 최적화
  Timer? _reloadDebounce;
  String _lastQueryKey = '';

  // 마커 아이콘 캐시
  late final Map<double, BitmapDescriptor> _markerIconCache = {
    BitmapDescriptor.hueRose:   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
    BitmapDescriptor.hueGreen:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    BitmapDescriptor.hueYellow: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    BitmapDescriptor.hueBlue:   BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    BitmapDescriptor.hueRed:    BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  };

  // 패널 열림 중 마커 대량 갱신 지연
  bool _pendingMarkers = false;
  Set<Marker>? _nextMarkers;

  @override
  void initState() {
    super.initState();
    _reloadFromServer(); // 초기 로드(기본 필터면 빈 결과일 수 있음)
  }

  @override
  void dispose() {
    _reloadDebounce?.cancel();
    super.dispose();
  }

  // ====== UI 핸들러 ======
  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    // 초기 스타일 적용
    try {
      await controller.setMapStyle(isDay ? dayMapStyle : nightMapStyle);
    } catch (_) {}
  }

  void _onMapTap(LatLng pos) {
    setState(() => isPanelOpen = false);
    _panelController.close();
  }

  void _toggleDayNight() async {
    setState(() => isDay = !isDay);
    // 리빌드 없이 스타일만 교체
    final c = mapController;
    if (c != null) {
      try {
        await c.setMapStyle(isDay ? dayMapStyle : nightMapStyle);
      } catch (_) {}
    }
    _scheduleReload();
  }

  // 시즌 토글은 모두 디바운스 리로드
  void _toggleSpring() { setState(() => isSpring = !isSpring); _scheduleReload(); }
  void _toggleSummer() { setState(() => isSummer = !isSummer); _scheduleReload(); }
  void _toggleFall()   { setState(() => isFall   = !isFall);   _scheduleReload(); }
  void _toggleWinter() { setState(() => isWinter = !isWinter); _scheduleReload(); }

  // ====== 쿼리 & 리로드 ======
  List<String> _selectedSeasons() {
    final s = <String>[];
    if (isSpring) s.add('SPRING');
    if (isSummer) s.add('SUMMER');
    if (isFall)   s.add('AUTUMN');
    if (isWinter) s.add('WINTER');
    return s;
  }

  List<String> _selectedDayTimes() => [isDay ? 'DAY' : 'NIGHT'];

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 200), _reloadFromServer);
  }

  Future<void> _reloadFromServer() async {
    final seasons  = _selectedSeasons();
    final dayTimes = _selectedDayTimes();
    final queryKey = '${seasons.join(",")}|${dayTimes.join(",")}';

    // 동일 조건이면 중복 요청 스킵
    if (queryKey == _lastQueryKey) return;
    _lastQueryKey = queryKey;

    if (seasons.isEmpty) {
      if (!mounted) return;
      setState(() => activeMarkers = {});
      return;
    }

    try {
      final points = await ThemeService.fetchThemes(
        seasons: seasons,
        dayTimes: dayTimes,
      );
      if (!mounted) return;

      if (points.isEmpty) {
        setState(() => activeMarkers = {});
        return;
      }

      final markers = points.map((p) {
        return Marker(
          markerId: MarkerId(p.id.toString()),
          position: LatLng(p.x, p.y),
          icon: _iconForSeasons(p.seasons),
          infoWindow: InfoWindow(
            title: 'ID: ${p.id}',
            snippet: '${p.seasons.join(", ")} / ${p.dayTimes.join(", ")}',
          ),
          onTap: () {
            if (!isPanelOpen) _panelController.open(); // 이미 열려있으면 중복 호출 X
            _loadDetail(p.id);                          // 상세 API 호출
            setState(() {
              isPanelOpen = true;
              selectedMarker = Marker(
                markerId: MarkerId(p.id.toString()),
                position: LatLng(p.x, p.y),
              );
            });
          },
        );
      }).toSet();

      _applyMarkers(markers);
    } catch (e) {
      // 실패 시 다음 토글 때 재요청되도록 queryKey 리셋
      _lastQueryKey = '';
      debugPrint('❌ 로드 실패: $e');
    }
  }

  void _applyMarkers(Set<Marker> next) {
    // 간단 디프: id 셋이 같으면 교체 스킵
    final prevIds = activeMarkers.map((m) => m.markerId).toSet();
    final nextIds = next.map((m) => m.markerId).toSet();
    if (prevIds.length == nextIds.length && prevIds.containsAll(nextIds)) {
      return;
    }

    // 패널이 크게 열려 있으면 마커 반영을 잠시 지연
    if (_panelMostlyOpen) {
      _pendingMarkers = true;
      _nextMarkers = next;
      return;
    }

    setState(() => activeMarkers = next);
  }

  double _getSeasonHue(List<String> seasons) {
    if (seasons.contains('SPRING')) return BitmapDescriptor.hueRose;
    if (seasons.contains('SUMMER')) return BitmapDescriptor.hueGreen;
    if (seasons.contains('AUTUMN')) return BitmapDescriptor.hueYellow;
    if (seasons.contains('WINTER')) return BitmapDescriptor.hueBlue;
    return BitmapDescriptor.hueRed; // 기본값
  }

  BitmapDescriptor _iconForSeasons(List<String> seasons) {
    final hue = _getSeasonHue(seasons);
    return _markerIconCache[hue]!;
  }

  // ====== 상세 호출 ======
  Future<void> _loadDetail(int id) async {
    setState(() {
      _loadingDetail = true;
      _detail = null;
      isPanelOpen = true;
    });

    final mySeq = ++_detailReqSeq;
    try {
      final d = await ThemeDetailApi.fetchThemeDetail(id);
      if (!mounted || mySeq != _detailReqSeq) return;

      setState(() {
        _detail = d;
        _loadingDetail = false;
      });

      // 필요시 포커싱(성능 이슈 없을 때만)
      // await mapController?.animateCamera(
      //   CameraUpdate.newLatLngZoom(LatLng(d.x, d.y), 10),
      // );
    } catch (e) {
      if (!mounted || mySeq != _detailReqSeq) return;
      setState(() {
        _loadingDetail = false;
        _detail = null;
      });
      debugPrint('❌ 상세 로드 실패: $e');
    }
  }

  // ====== 스타일 ======
  ButtonStyle _buttonStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      minimumSize: const Size(60, 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // keep-alive 유지

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(target: _center, zoom: 7.0),
          markers: activeMarkers,
          // 성능 옵션
          compassEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          indoorViewEnabled: false,
          buildingsEnabled: false,
          trafficEnabled: false,
          // 제스처 동적 제어
          scrollGesturesEnabled: _mapGesturesEnabled,
          zoomGesturesEnabled: _mapGesturesEnabled,
          rotateGesturesEnabled: _mapGesturesEnabled,
          tiltGesturesEnabled: _mapGesturesEnabled,
          onTap: _onMapTap,
        ),

        // 슬라이딩 패널
        PlacePanel(
          isOpen: isPanelOpen,
          loading: _loadingDetail,
          detail: _detail,
          controller: _panelController,
          onPanelSlide: (pos) {
            // 패널 열림 비율에 따라 제스처 제어
            final enabled = pos < 0.30;
            if (enabled != _mapGesturesEnabled) {
              setState(() => _mapGesturesEnabled = enabled);
            }
            // 패널이 다시 내려오면 지연된 마커 반영
            final mostlyOpen = pos >= 0.30;
            if (_panelMostlyOpen != mostlyOpen) {
              _panelMostlyOpen = mostlyOpen;
              if (!mostlyOpen && _pendingMarkers && _nextMarkers != null) {
                setState(() {
                  activeMarkers = _nextMarkers!;
                  _pendingMarkers = false;
                  _nextMarkers = null;
                });
              }
            }
          },
          onPlanPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TravelCourseForm(
                  imageUrl: _detail?.themeImage ?? '',
                  title: _detail?.title ?? '여행 계획',
                  tags: _detail?.birds.map((b) => b.name).toList() ?? const [],
                  description: _detail?.locationIntro ?? '',
                ),
              ),
            );
          },
        ),

        // 상단 토글 바
        Positioned(
          top: 48,
          left: 32,
          right: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _toggleDayNight,
                icon: Icon(
                  isDay ? Icons.wb_sunny : Icons.nightlight_round,
                  color: isDay ? Colors.orange : Colors.white,
                  size: 18,
                ),
                label: Text(
                  isDay ? '낮' : '밤',
                  style: TextStyle(
                    color: isDay ? Colors.black : Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: _buttonStyle(isDay ? Colors.white : Colors.black),
              ),
              SeasonToggleButton(isActive: isSpring, label: '봄',  activeColor: Colors.pinkAccent, onPressed: _toggleSpring),
              SeasonToggleButton(isActive: isSummer, label: '여름', activeColor: Colors.green,      onPressed: _toggleSummer),
              SeasonToggleButton(isActive: isFall,   label: '가을', activeColor: Colors.yellow,     onPressed: _toggleFall),
              SeasonToggleButton(isActive: isWinter, label: '겨울', activeColor: Colors.blue,       onPressed: _toggleWinter),
            ],
          ),
        ),
      ],
    );
  }
}
