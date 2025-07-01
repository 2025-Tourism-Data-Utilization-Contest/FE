import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:showings/widgets/season_button.dart';
import 'package:showings/settings/season_markers.dart';
import 'package:showings/widgets/place_panel.dart';
import 'package:showings/screens/travel_course_page.dart';
import 'package:showings/settings/thema.dart';

class CourseTab extends StatefulWidget {
  const CourseTab({super.key});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(36.5, 127.8);
  // 현재 활성화된 마커 집합
  Set<Marker> activeMarkers = {};
  late Marker selectedMarker;

  bool isPanelOpen = false;

  bool isDay = true;
  bool isSpring = false;
  bool isSummer = false;
  bool isFall = false;
  bool isWinter = false;

  String? selectedTag;

  @override
  void initState() {
    super.initState();
    _updateActiveMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _toggleDayNight() {
    setState(() {
      isDay = !isDay;
    });
  }

  void _updateActiveMarkers() async{
    // 시즌별 마커 저장
    final seasonMarkerMap = {
      'spring': await SeasonMarkers.loadSpringMarkers(context),
      'summer': SeasonMarkers.summerMarkers,
      'fall': SeasonMarkers.fallMarkers,
      'winter': SeasonMarkers.winterMarkers,
    };

    // 시즌별 활성 여부 저장
    final seasonActiveMap = {
      'spring': isSpring,
      'summer': isSummer,
      'fall': isFall,
      'winter': isWinter,
    };

    final newMarkers = <Marker>{};

    seasonMarkerMap.forEach((season, markers) {
      if (seasonActiveMap[season] == true) {
        for (var m in markers) {
          newMarkers.add(
            m.copyWith(
              onTapParam: () {
                setState(() {
                  selectedMarker = m;
                  isPanelOpen = true;
                });
              },
            ),
          );
        }
      }
    });

    setState(() {
      activeMarkers = newMarkers;
    });
  }

  // 재사용할 버튼 스타일 함수 (배경색만 다르게 받도록)
  ButtonStyle _buttonStyle(Color bgColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: bgColor,
      minimumSize: const Size(60, 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 7.0,
          ),
          markers: activeMarkers,
          style: isDay ? dayMapStyle : nightMapStyle,  // 낮밤에 따라 스타일 선택
          onTap: (LatLng position) {
            setState(() {
              isPanelOpen = false;
            });
            mapController.animateCamera(
              CameraUpdate.newLatLng(_center),
            );
          },
        ),
        PlacePanel(isPanelOpen: isPanelOpen),
        if (isPanelOpen)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ⬅️ "자세히 보기" 버튼
                OutlinedButton(
                  onPressed: () {
                    // 원하는 액션
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF6C6C84),
                      width: 3.0, // ⬅ 테두리 굵기 설정
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                    backgroundColor: const Color(0xFFF5F5F7),
                  ),
                  child: const Text(
                    '자세히 보기',
                    style: TextStyle(
                      color: Color(0xFF4D4D4D),
                      fontSize: 18,
                    ),
                  ),
                ),

                // ➡️ "여행 계획 만들기" 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelCourseForm(
                          imageUrl: 'https://img.khan.co.kr/news/2022/12/18/news-p.v1.20221118.b04d6356099a419ba05abbf5fddc7359_Z1.jpg',
                          title: '흑두루미가 날아드는 순천만 습지',
                          tags: ['흑두루미', '민댕기물떼새, 검은머리물떼새'],
                          description: '순천만 습지는 한국 연안습지 중 최초로 람사르 습지로 지정된 곳으로, 다양한 생태계가 살아 숨쉬는 곳입니다.',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DDD70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(36),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  ),
                  child: const Text(
                    '여행계획 만들기',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
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
                  isDay ? '낯' : '밤',
                  style: TextStyle(
                    color: isDay ? Colors.black : Colors.white,
                    fontSize: 14,
                  ),
                ),
                style: _buttonStyle(isDay ? Colors.white : Colors.black),
              ),
              SeasonToggleButton(
                isActive: isSpring,
                label: '봄',
                activeColor: Colors.pinkAccent,
                onPressed: () {
                  setState(() {
                    isSpring = !isSpring;
                    _updateActiveMarkers();  // 상태 변경 후 마커 갱신
                  });
                },
              ),
              SeasonToggleButton(
                isActive: isSummer,
                label: '여름',
                activeColor: Colors.green,
                onPressed: () {
                  setState(() {
                    isSummer = !isSummer;
                    _updateActiveMarkers();  // 상태 변경 후 마커 갱신
                  });
                },
              ),
              SeasonToggleButton(
                isActive: isFall,
                label: '가을',
                activeColor: Colors.yellow,
                onPressed: () {
                  setState(() {
                    isFall = !isFall;
                    _updateActiveMarkers();  // 상태 변경 후 마커 갱신
                  });
                },
              ),
              SeasonToggleButton(
                isActive: isWinter,
                label: '겨울',
                activeColor: Colors.blue,
                onPressed: () {
                  setState(() {
                    isWinter = !isWinter;
                    _updateActiveMarkers();  // 상태 변경 후 마커 갱신
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

