import 'package:flutter/material.dart';
import 'package:showings/widgets/nearby_place_card.dart';
import 'package:showings/settings/call_api.dart';
import 'package:showings/screens/place_detail_page.dart';

import '../settings/place.dart';

class AddTravelDestinationScreen extends StatefulWidget {
  const AddTravelDestinationScreen({super.key});

  @override
  State<AddTravelDestinationScreen> createState() => _AddTravelDestinationScreenState();
}

class _AddTravelDestinationScreenState extends State<AddTravelDestinationScreen> {
  final List<String> filters = ['숙박', '관광지','레저','문화시설','음식점', '축제공연행사', '쇼핑'];
  String selectedFilter = '숙박';
  String searchKeyword = '';
  List<Map<String, dynamic>> placeList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchPlacesByFilter(); // 초기 로딩
  }

  Future<void> fetchPlacesByFilter() async {
    setState(() => isLoading = true);

    try {
      List<Map<String, dynamic>> rawItems = [];

      final Map<String, Future<List<Map<String, dynamic>>> Function()> fetchFunctions = {
        '숙박': () => getTouristSpots("32"),
        '관광지': () => getTouristSpots("12"),
        '레저': () => getTouristSpots("28"),
        '문화시설': () => getTouristSpots("14"),
        '음식점': () => getTouristSpots("39"),
        // '여행코스': () => getTouristSpots("25"),
        // '생태': getGreenSpots,
        '축제공연행사': () => getTouristSpots("15"),
        '쇼핑': () => getTouristSpots("38"),
      };

      rawItems = await (fetchFunctions[selectedFilter]?.call() ?? Future.value([]));


      setState(() {
        placeList = rawItems.map((item) {
          return {
            'imagePath': item['firstimage'] ?? item['mainimage'] ?? 'assets/images/example.png',
            'title': item['title'] ?? '',
            'subtitle': item['addr1'] ?? item['addr'] ?? '',
            'dist' : item['dist'] ?? '',
            'contentId' : item['contentid'] ?? '',
            'contentTypeId' : item['contenttypeid'] ?? ''
          };
        }).toList();
      });
    } catch (e) {
      print('❌ API 오류: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '$selectedFilter',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDestinationGrid(),
            ),
          ],
        ),
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
          fetchPlacesByFilter();
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
              selectedColor: const Color(0xFF333A45),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                  searchKeyword = '';
                });
                fetchPlacesByFilter();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDestinationGrid() {
    final places = placeList;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PlaceDetailScreen(
                  title: place['title']!,
                  contentId: place['contentId']!,
                  contentTypeId: place['contentTypeId']!, // 공백 제거
                  address: place['subtitle']!,
                ),
              ),
            ).then((returnedPlace) {
              if (returnedPlace != null && returnedPlace is Place) {
                Navigator.pop(context, returnedPlace); // DetailScreen → AddScreen → DetailScreen까지 한 번에 전달
              }
            });
          },
          child: NearbyPlaceCard(
            imagePath: place['imagePath']!,
            title: place['title']!,
            subtitle: place['subtitle']!,
            distanceString: place['dist'],
          ),
        );
      },
    );
  }
}
