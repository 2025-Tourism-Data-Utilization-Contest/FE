import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'my_page.dart';
import 'course_page.dart';
import 'package:showings/screens/social_page.dart';
import 'package:showings/widgets/nearby_place_card.dart';
import 'package:showings/widgets/experience_card.dart';
import 'package:showings/settings/call_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool showTripCard = true;

  final _tabBuilders = <Widget Function()>[
        () => const HomeTab(),
        () => const CourseTab(),
        () => const SocialPage(),
        () => const MyPageScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => showTripCard = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => showTripCard = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _tabBuilders[_currentIndex](),

          if (_currentIndex == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight + 17,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(position: slide, child: child);
                },
                child: showTripCard
                    ? _buildTripCard(context)
                    : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context) {
    return Material(
      elevation: 6,
      color: const Color(0xCC42415D),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.schedule, color: Colors.white, size: 30),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Day 1 ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        TextSpan(
                          text: '흑두루미가 날아드는 순천만 습지',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '여행코스 1  |  5월 16일(금) ~ 5월 17일(토)',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => showTripCard = false),
              child: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}


/// =======================
/// HomeTab (KeepAlive 제거)
/// =======================
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Position? _currentPosition;
  List<dynamic> _spots = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  final int _itemsPerPage = 5;
  bool _isLoading = false;
  bool _hasMore = true;

  List<Map<String, dynamic>> _experiences = [];
  bool _isLoadingExperience = true;

  @override
  void initState() {
    super.initState();
    _getLocationPermissionAndPosition();
    _fetchExperienceData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        _loadMoreSpots();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchExperienceData() async {
    setState(() => _isLoadingExperience = true);
    try {
      final data = await getFestivalExperiences();
      if (!mounted) return;
      setState(() {
        _experiences = data;
        _isLoadingExperience = false;
      });
    } catch (e) {
      debugPrint('❌ 체험 데이터 로딩 실패: $e');
      if (mounted) setState(() => _isLoadingExperience = false);
    }
  }

  Future<void> _loadMoreSpots() async {
    if (_isLoading || !_hasMore || _currentPosition == null) return;
    setState(() => _isLoading = true);

    try {
      final newSpots = await TouristService.fetchTouristSpots(
        mapX: _currentPosition!.longitude,
        mapY: _currentPosition!.latitude,
        pageNo: _currentPage,
        numOfRows: _itemsPerPage,
      );

      if (!mounted) return;
      if (newSpots.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        setState(() {
          _spots.addAll(newSpots);
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('❌ 관광지 추가 로드 실패: $e');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _getLocationPermissionAndPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ 위치 서비스 꺼져 있음');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('⛔ 권한 영구 거부됨. 설정으로 유도 필요');
        return;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (!mounted) return;
        setState(() => _currentPosition = position);

        debugPrint('📍 위치: ${position.latitude}, ${position.longitude}');

        try {
          final placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
            localeIdentifier: 'ko',
          );

          if (placemarks.isNotEmpty) {
            if (!mounted) return;
            setState(() {
              _spots.clear();
              _currentPage = 1;
              _hasMore = true;
            });
            await _loadMoreSpots(); // 첫 로딩
          }
        } catch (e) {
          debugPrint('❌ 지오코딩 실패: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ 위치 요청 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('HOT Place!', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          _spots.isEmpty || _isLoading
              ? const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          )
              : SizedBox(
            height: 300,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _spots.length + (_isLoading ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index >= _spots.length) {
                  return const SizedBox(
                    width: 40,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final spot = _spots[index];
                final title = spot['title'] ?? '이름 없음';
                final address = spot['addr1'] ?? '주소 정보 없음';
                final imageUrl =
                    spot['firstimage'] ?? 'https://via.placeholder.com/150';
                final distStr = spot['dist'];

                return NearbyPlaceCard(
                  imagePath: imageUrl,
                  title: title,
                  subtitle: address,
                  distanceString: distStr,
                );
              },
            ),
          ),
          const Divider(thickness: 1, height: 1),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
            Text('프로그램 및 체험', style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isLoadingExperience
                ? const CircularProgressIndicator()
                : Column(
              children: _experiences.map((exp) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ExperienceCard(
                    imagePath:
                    exp['firstimage'] ?? 'https://via.placeholder.com/150',
                    title: exp['title'] ?? '제목 없음',
                    period:
                    '${exp['eventstartdate'] ?? '?'} ~ ${exp['eventenddate'] ?? '?'}',
                    price: exp['addr1'] ?? '주소 정보 없음',
                    reviewCount: '',
                    reviewDate: '',
                    reviewText: '',
                    reviewThumbnail: '',
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 바텀 네비게이션
/// =======================
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: '코스'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: '소셜'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
      ],
    );
  }
}
