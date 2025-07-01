import 'package:flutter/material.dart';
import 'my_page.dart';
import 'course_page.dart';
import 'package:showings/widgets/nearby_place_card.dart';
import 'package:showings/widgets/experience_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _tabs = const [
    HomeTab(),
    CourseTab(),
    MyPageScreen(),
  ];

  bool showTripCard = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: _tabs, // 각 탭 화면
          ),

          // 🔹 TripCard 고정 표시
          if (showTripCard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0, // ← 위로 올림
              child: Material(
                elevation: 6,
                color: const Color(0xCC42415D),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.schedule, color: Colors.white, size: 30), // 더 크게
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Day 1 ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20, // 크게
                                    ),
                                  ),
                                  TextSpan(
                                    text: '흑두루미가 날아드는 순천만 습지',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '여행코스 1  |  5월 16일(금) ~ 5월 17일(토)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16, // 크게
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showTripCard = false;
                            });
                          },
                          child: const Icon(Icons.chevron_right, color: Colors.white, size: 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.jumpToPage(index);
          setState(() => _currentIndex = index);
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '코스'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '나만의 여행코스 만들기',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('내 주변 관광지',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),

            // 주변 관광지 가로 리스트
            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 10,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return NearbyPlaceCard(
                    imagePath: 'assets/images/example.png',
                    title: '주변 관광지',
                    subtitle: '세부정보',
                    price: '66,000 / 1박',
                  );
                },
              ),
            ),

            const Divider(thickness: 1, height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('프로그램 및 체험',
                  style: Theme.of(context).textTheme.titleLarge),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // 외부 SingleChildScrollView에 스크롤 위임
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return ExperienceCard(
                    imagePath: 'assets/images/example2.jpg',
                    title: '갯벌체험',
                    period: '2022.10.10 ~ 2022.10.23',
                    price: '0원',
                    reviewCount: '1,422',
                    reviewDate: '2025.05.17',
                    reviewText: '너무 좋아요',
                    reviewThumbnail: 'assets/images/example2.jpg',
                  );
                },
              ),
            ),
            const SizedBox(height: 32), // 하단 여백
          ],
        ),
      ),
    );
  }
}

