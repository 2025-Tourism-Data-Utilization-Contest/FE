import 'package:flutter/material.dart';
import 'package:showings/widgets/nearby_place_card.dart';

class AddTravelDestinationScreen extends StatefulWidget {
  const AddTravelDestinationScreen({super.key});

  @override
  State<AddTravelDestinationScreen> createState() => _AddTravelDestinationScreenState();
}

class _AddTravelDestinationScreenState extends State<AddTravelDestinationScreen> {
  final List<String> filters = ['숙박', '관광지', '레저', '문화시설', '축제공연행사'];
  String selectedFilter = '숙박';
  String searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행지 추가하기'),
        leading: const BackButton(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$selectedFilter', // ✅ 선택된 필터에 따라 바뀜
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          Expanded(child: _buildDestinationGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchKeyword = value;
          });
        },
        decoration: const InputDecoration(
          hintText: '장르 혹은 지역으로 검색하세요',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              selectedColor: const Color(0xFF333A45), // 어두운 회색/남색
              backgroundColor: Colors.grey[200], // 밝은 회색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide.none, // 외곽선 제거
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDestinationGrid() {
    final dummyPlaces = List.generate(8, (index) {
      return {
        'imagePath': 'assets/images/example.png', // 실제 애셋 경로 사용
        'title': '세인트 존스',
        'subtitle': '세부정보',
      };
    });

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: dummyPlaces.length,
      itemBuilder: (context, index) {
        final place = dummyPlaces[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTravelDestinationScreen(), // 또는 상세 페이지
              ),
            );
          },
          child: NearbyPlaceCard(
            imagePath: place['imagePath'] as String,
            title: place['title'] as String,
            subtitle: place['subtitle'] as String,
            price: '66,000 / 1박',
          ),
        );
      },
    );
  }
}
