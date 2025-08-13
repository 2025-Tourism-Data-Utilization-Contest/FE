import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showings/screens/detail_views/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../settings/place.dart';

class TouristSpotDetailView extends StatefulWidget {
  final Map<String, dynamic> data;

  const TouristSpotDetailView({super.key, required this.data});

  @override
  State<TouristSpotDetailView> createState() => _TouristSpotDetailViewState();
}

class _TouristSpotDetailViewState extends State<TouristSpotDetailView> {
  late Map<String, dynamic> common;
  late Map<String, dynamic> intro;
  late List<dynamic> infoList;
  late List<dynamic> images;
  int _currentImageIndex = 0;

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
      appBar: AppBar(title: Text(common['title'] ?? '관광지 정보')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImageCarousel(),
          const SizedBox(height: 16),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildDetailInfo(),
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
        )
      ),
    );
  }

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
                          images: images.cast<String>(), // 이미 List<String>이라 그대로 넘기면 됨
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
        Text(common['addr1'] ?? '-', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        Text(intro['infocenter'] ?? '-', style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 6),
        if (intro['usetime'] != null)
          Text('운영시간: ${_stripHtml(intro['usetime'])}', style: const TextStyle(fontSize: 14)),
        if (intro['restdate'] != null)
          Text('휴무일: ${_stripHtml(intro['restdate'])}', style: const TextStyle(fontSize: 14)),
        if (intro['parking'] != null)
          Text('주차: ${intro['parking']}', style: const TextStyle(fontSize: 14)),
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
          const SizedBox(height: 12),
          Text(_stripHtml(common['overview']), style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  Widget _buildDetailInfo() {
    if (infoList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('상세 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...infoList.map((info) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ${info['infoname'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(_stripHtml(info['infotext'] ?? '')),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}