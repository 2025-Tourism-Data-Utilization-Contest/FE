import 'package:flutter/material.dart';

class BirdDetailScreen extends StatefulWidget {
  const BirdDetailScreen({super.key});

  @override
  State<BirdDetailScreen> createState() => _BirdDetailScreenState();
}

class _BirdDetailScreenState extends State<BirdDetailScreen> {
  String? selectedLocation;

  final List<String> locations = [
    '순천만 습지',
    '대구 달성 습지',
    '서산 간척지',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // 공유 기능
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지
            Image.asset(
              'assets/images/hooded_crane.jpg',
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 & 학명
                  const Text(
                    '흑두루미',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Grus monacha Temminck, 1835',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 선택 가능한 Chip들
                  Wrap(
                    spacing: 8,
                    children: locations.map((location) {
                      return ChoiceChip(
                        label: Text(location),
                        selected: selectedLocation == location,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedLocation = selected ? location : null;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 설명 텍스트
                  const Text(
                    '흑두루미는 "검은두루미"이자 야생생물 보호종이며, 두루미과에 속합니다. '
                        '몸길이는 약 100cm이며, 흑색의 얼굴과 목, 흰 머리깃이 특징입니다. '
                        '주요 번식지는 시베리아 동부이며, 겨울에는 한국, 일본, 중국 남부 지역에서 월동합니다. '
                        '주로 갯벌, 하천 주변 습지에서 먹이를 찾으며, 보호가 필요한 종입니다.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
