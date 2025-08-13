import 'package:flutter/material.dart';
import 'package:showings/screens/detail_views/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../settings/place.dart';

class LodgingDetailView extends StatefulWidget {
  final Map<String, dynamic> data;

  const LodgingDetailView({super.key, required this.data});

  @override
  State<LodgingDetailView> createState() => _LodgingDetailViewState();
}

class _LodgingDetailViewState extends State<LodgingDetailView> {
  late Map<String, dynamic> common;
  late Map<String, dynamic> intro;
  late List<dynamic> infoList;
  late List<String> images;

  @override
  void initState() {
    super.initState();
    final data = widget.data;
    common = data['common'] ?? {};
    intro = data['intro'] ?? {};
    infoList = data['infoList'] ?? [];
    images = data['images'] ?? [];
  }

  String _parseHomepage(String? html) {
    final match = RegExp(r'href\s*=\s*"([^"]+)"').firstMatch(html ?? '');
    return match != null ? match.group(1)! : '-';
  }

  String _stripHtml(String? text) {
    return (text ?? '').replaceAll(RegExp(r'<br\s*/?>'), '\n').replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(common['title'] ?? '숙소 정보'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImageCarousel(),
          const SizedBox(height: 16),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildRoomList(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () {
            final place = Place(
                name: common['title'] ?? '이름 없음',
                imageUrl: images.isNotEmpty ? images.first : '',
                latitude: double.tryParse(common['mapy'] ?? '') ?? 0.0,
                longitude: double.tryParse(common['mapx'] ?? '') ?? 0.0,
                contentId: common['contentid'] ?? '',
                contentTypeId: common['contenttypeid'] ?? '',
                address: common['addr1'] ?? ''
            );

            Navigator.pop(context, place);
          },
          child: const Text('일정에 추가하기'),
        ),
      ),
    );
  }

  int _currentImageIndex = 0; // 상태로 이동

  Widget _buildImageCarousel() {
    if (images.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullscreenImageViewer(
                        images: images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentImageIndex + 1} / ${images.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(common['addr1'] ?? '주소 정보 없음', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        Text(common['tel'] ?? '전화번호 없음', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 16),

        if (intro['checkintime'] != null || intro['checkouttime'] != null)
          Text(
            '체크인 ${intro['checkintime'] ?? '-'} / 체크아웃 ${intro['checkouttime'] ?? '-'}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        const SizedBox(height: 8),

        if (intro['roomtype'] != null)
          Text('객실 유형: ${intro['roomtype']}', style: const TextStyle(fontSize: 14)),

        if (intro['roomcount'] != null)
          Text('객실 수: ${intro['roomcount']}', style: const TextStyle(fontSize: 14)),

        if (intro['parkinglodging'] != null)
          Text('주차: ${intro['parkinglodging']}', style: const TextStyle(fontSize: 14)),

        if (intro['subfacility'] != null)
          Text('부대시설: ${intro['subfacility']}', style: const TextStyle(fontSize: 14)),

        if (intro['foodplace'] != null)
          Text('식음 시설: ${intro['foodplace']}', style: const TextStyle(fontSize: 14)),

        if (common['homepage'] != null)
          InkWell(
            onTap: () async {
              final url = Uri.tryParse(_parseHomepage(common['homepage']));
              if (url != null) {
                final launched = await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication, // 👈 외부 앱 강제
                );
                if (!launched) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크를 열 수 없습니다')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('유효하지 않은 링크입니다')),
                );
              }
            },
            child: Text(
              '홈페이지 방문하기',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
              ),
            ),
          ),

        if (common['overview'] != null) ...[
          const SizedBox(height: 16),
          Text(
            common['overview'],
            style: const TextStyle(fontSize: 14),
          ),
        ]
      ],
    );
  }

  Widget _buildRoomList() {
    if (infoList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 12),
          Text(
            '',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '객실 정보',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...infoList.map((room) => _buildRoomCard(room)).toList(),
      ],
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final img = room['roomimg1'];
    final title = room['roomtitle'] ?? '객실명 없음';
    final size = room['roomsize1'] ?? '-';
    final people = '${room['roombasecount'] ?? '?'}명 ~ ${room['roommaxcount'] ?? '?'}명';
    final price = room['roomoffseasonminfee1'] ?? '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (img != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(img, width: 80, height: 80, fit: BoxFit.cover),
              )
            else
              Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.bed, size: 40),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('크기: $size / 정원: $people'),
                  Text('비수기 요금: $price원'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
