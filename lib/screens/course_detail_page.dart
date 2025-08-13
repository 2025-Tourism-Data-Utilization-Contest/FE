import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:showings/screens/place_add_page.dart';
import 'package:showings/screens/place_detail_page.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';


import '../settings/call_api.dart';
import '../settings/place.dart';
import '../settings/travel_course.dart';

class TravelCourseDetailScreen extends StatefulWidget {
  final TravelCourse travelCourse;
  final int? courseIndex;

  const TravelCourseDetailScreen({
    super.key,
    required this.travelCourse,
    this.courseIndex,
  });

  @override
  State<TravelCourseDetailScreen> createState() => _TravelCourseDetailScreenState();
}

class _TravelCourseDetailScreenState extends State<TravelCourseDetailScreen> {
  int selectedDay = 1;
  GoogleMapController? _mapController; // ✅ 지도 컨트롤러 저장
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final TextEditingController _titleController = TextEditingController();


  Future<BitmapDescriptor> _createNumberMarker(int number) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double size = 140; // 기존 100 → 140
    const double radius = 65; // 기존 45 → 65

    final Paint paint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size / 2, size / 2), radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 50, // 기존 36 → 50
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size / 2) - (textPainter.width / 2),
        (size / 2) - (textPainter.height / 2),
      ),
    );

    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }



  Future<void> _updateMapOverlays(List<Place> places) async {
    final Set<Marker> markers = {};

    for (int i = 0; i < places.length; i++) {
      final icon = await _createNumberMarker(i + 1);
      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(places[i].latitude, places[i].longitude),
          icon: icon,
          infoWindow: InfoWindow(title: places[i].name),
        ),
      );
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route_line'),
      color: Colors.black,
      width: 3,
      points: places.map((p) => LatLng(p.latitude, p.longitude)).toList(),
    );

    setState(() {
      _markers = markers;
      _polylines = {polyline};
    });
  }

  void _onSavePressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('여행 코스 저장'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('코스 이름을 입력해주세요.'),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '예: 부산 2박 3일 여행',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _titleController.clear();
                Navigator.pop(context);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final title = _titleController.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(context);
                  _saveTravelCourse(title);
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTravelCourse(String title) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedCourse = TravelCourse(
      title: title,
      startDate: widget.travelCourse.startDate,
      endDate: widget.travelCourse.endDate,
      days: widget.travelCourse.days,
      author: widget.travelCourse.author,
      id: widget.travelCourse.id,
    );
    final jsonStr = jsonEncode(updatedCourse.toJson());

    int count = prefs.getInt('travel_course_count') ?? 0;

    if (widget.courseIndex != null) {
      // ✅ 기존 인덱스 덮어쓰기
      await prefs.setString('travel_course_${widget.courseIndex}', jsonStr);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 일정이 수정되었습니다.')),
      );
    } else {
      // ✅ 새 코스 추가
      await prefs.setString('travel_course_$count', jsonStr);
      await prefs.setInt('travel_course_count', count + 1);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('여행 일정이 저장되었습니다.')),
      );
    }

    _titleController.clear();

    // ✅ 화면 두 단계 뒤로 나가기
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }



  @override
  Widget build(BuildContext context) {
    // 여행 기간 계산
    final travelCourse = widget.travelCourse;

    final totalDays = travelCourse.days.length;
    final List<String> days = List.generate(totalDays, (i) => 'Day ${i + 1}');

    final currentDate = travelCourse.startDate.add(Duration(days: selectedDay - 1));
    final dateText = DateFormat('M월 d일 (E)', 'ko_KR').format(currentDate);

    final dayPlaces = travelCourse.days[selectedDay - 1].places;

    void _fitMapToMarkers(List<Place> places) {
      if (_mapController == null || places.isEmpty) return;

      if (places.length == 1) {
        // 마커가 1개일 때는 LatLngBounds가 에러 날 수 있으므로 개별 처리
        final onlyPlace = places.first;
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(onlyPlace.latitude, onlyPlace.longitude),
            14.5,
          ),
        );
        return;
      }

      final latitudes = places.map((p) => p.latitude);
      final longitudes = places.map((p) => p.longitude);

      final southwest = LatLng(
        latitudes.reduce((a, b) => a < b ? a : b),
        longitudes.reduce((a, b) => a < b ? a : b),
      );
      final northeast = LatLng(
        latitudes.reduce((a, b) => a > b ? a : b),
        longitudes.reduce((a, b) => a > b ? a : b),
      );

      final bounds = LatLngBounds(southwest: southwest, northeast: northeast);

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('여행코스'),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _onSavePressed,
            child: const Text(
              '완료',
              style: TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 지도 + Day 탭
          SizedBox(
            height: 250, // 지도 + 버튼 공간 확보
            child: Stack(
              children: [
                // 지도
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(34.9504, 127.4878),
                      zoom: 13,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitMapToMarkers(dayPlaces);
                      _updateMapOverlays(dayPlaces); // ✅ 마커 업데이트
                    },
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Align(
                    alignment: Alignment.center, // ← 가운데 정렬 핵심
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(days.length, (index) {
                          final isSelected = selectedDay == index + 1;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                days[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Colors.grey[800],
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedDay = index + 1;
                                });

                                // WidgetsBinding을 이용해 build 이후에 실행
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  final newPlaces = widget.travelCourse.days[index].places;
                                  _fitMapToMarkers(newPlaces);
                                  _updateMapOverlays(newPlaces);
                                });
                              },
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Day 날짜 텍스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Day $selectedDay  $dateText',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 일정 리스트
          Expanded(
            child: ReorderableListView.builder(
              itemCount: dayPlaces.length + 1, // ✅ + 버튼 항목 포함
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.05,
                    child: child,
                  ),
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onReorder: (oldIndex, newIndex) {
                final lastIndex = dayPlaces.length;
                if (oldIndex >= lastIndex || newIndex > lastIndex - 1) return; // ✅ +버튼 드래그 방지

                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = dayPlaces.removeAt(oldIndex);
                  dayPlaces.insert(newIndex, item);
                });
                _updateMapOverlays(dayPlaces);
              },
              itemBuilder: (context, index) {
                // ✅ 마지막 index면 + 버튼
                if (index == dayPlaces.length) {
                  return Padding(
                    key: const ValueKey('add_button'),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTravelDestinationScreen(),
                          ),
                        ).then((selectedPlace) async {
                          if (selectedPlace != null && selectedPlace is Place) {
                            setState(() {
                              widget.travelCourse.days[selectedDay - 1].places.add(selectedPlace);
                            });
                            selectedPlace.orderInDay = widget.travelCourse.days[selectedDay - 1].places.length;
                            selectedPlace.dayNumber = selectedDay;

                            // ✅ API 호출
                            try {
                              final orderInDay = widget.travelCourse.days[selectedDay - 1].places.length;
                              await RouteService.addPlace(
                                routeId: widget.travelCourse.id,
                                dayNumber: selectedDay,
                                orderInDay: orderInDay,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('장소 등록 실패: $e')),
                              );
                            }
                            final updatedPlaces = widget.travelCourse.days[selectedDay - 1].places;
                            await _updateMapOverlays(updatedPlaces);
                            _fitMapToMarkers(updatedPlaces);
                          }
                        });
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 28),
                        ),
                      ),
                    ),
                  );
                }

                // ✅ 일반 place 카드
// ✅ 일반 place 카드 (여백 제거 + 글씨/아이콘 크기 키움)
                final place = dayPlaces[index];

                return Card(
                  key: ValueKey('place_$index'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceDetailScreen(
                            title: place.name,
                            contentId: place.contentId,
                            contentTypeId: place.contentTypeId,
                            address: place.address,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 썸네일
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Image.network(
                                place.imageUrl,
                                width: 100,  // 사진 넓이
                                height: 100, // 사진 높이
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 28),
                                ),
                              ),
                              // 번호 배지
                              Positioned(
                                left: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 텍스트 + 삭제 버튼
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                // 제목
                                Expanded(
                                  child: Text(
                                    place.name,
                                    style: const TextStyle(
                                      fontSize: 18, // 글씨 크게
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // 삭제 버튼
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent, size: 28), // 아이콘 크게
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('삭제할까요?'),
                                        content: Text('${place.name}을(를) 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('취소'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                dayPlaces.removeAt(index);
                                              });
                                              final updated = widget.travelCourse.days[selectedDay - 1].places;
                                              _updateMapOverlays(updated);
                                              _fitMapToMarkers(updated);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('삭제'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
