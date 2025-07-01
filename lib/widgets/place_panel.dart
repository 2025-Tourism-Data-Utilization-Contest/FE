import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:showings/widgets/nearby_place_card.dart';
import 'package:showings/widgets/experience_card.dart';
import 'place_card.dart';

class PlacePanel extends StatefulWidget {
  final bool isPanelOpen;

  const PlacePanel({super.key, required this.isPanelOpen});

  @override
  State<PlacePanel> createState() => _PlacePanelState();
}

class _PlacePanelState extends State<PlacePanel> {
  String? selectedTag;

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      panel: Column(
        children: [
          // 패널 상단 손잡이
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PlaceCard(
                    imageUrl:
                    'https://img.khan.co.kr/news/2022/12/18/news-p.v1.20221118.b04d6356099a419ba05abbf5fddc7359_Z1.jpg',
                    title: '흑두루미가 날아드는 순천만 습지',
                    tags: ['흑두루미', '민댕기물떼새, 검은머리물떼새'],
                    description:
                    '순천만 습지는 한국 연안습지 중 최초로 람사르 습지로 지정된 곳으로, 다양한 생태계가 살아 숨쉬는 곳입니다.',
                    selectedTag: selectedTag,
                    onTagPressed: (tag) {
                      setState(() {
                        selectedTag = tag;
                      });
                    },
                    onMorePressed: () {
                      // 더보기 눌렀을 때
                    },
                  ),

                  // 구분선
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // 추가 콘텐츠
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

                  // 체험 카드 여러 개 (고정된 개수 반복)
                  Padding(
                    padding: const EdgeInsets.symmetric(),
                    child: Column(
                      children: List.generate(5, (index) {
                        return Column(
                          children: [
                            ExperienceCard(
                              imagePath: 'assets/images/example2.jpg',
                              title: '갯벌체험',
                              period: '2022.10.10 ~ 2022.10.23',
                              price: '0원',
                              reviewCount: '1,422',
                              reviewDate: '2025.05.17',
                              reviewText: '너무 좋아요',
                              reviewThumbnail: 'assets/images/example2.jpg',
                            ),
                            const SizedBox(height: 8), // 카드와 구분선 사이 여백
                            if (index != 4) const Divider(thickness: 0.8),
                            const SizedBox(height: 8), // 구분선과 다음 카드 사이 여백
                          ],
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      minHeight: widget.isPanelOpen ? 300 : 0,
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
    );
  }
}
