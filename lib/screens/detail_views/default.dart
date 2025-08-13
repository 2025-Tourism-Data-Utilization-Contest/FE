import 'package:flutter/material.dart';

class DefaultDetailView extends StatelessWidget {
  final Map<String, dynamic> data;

  const DefaultDetailView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final common = data['common'] ?? {};
    final images = data['images'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(common['title'] ?? '상세 정보'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildImage(images, common),
          const SizedBox(height: 16),
          Text(
            common['overview'] ?? '소개 정보가 없습니다.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (common['addr1'] != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(common['addr1'], style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (common['tel'] != null)
            Row(
              children: [
                const Icon(Icons.phone, size: 20),
                const SizedBox(width: 4),
                Text(common['tel'], style: const TextStyle(fontSize: 14)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImage(List<dynamic> images, Map<String, dynamic> common) {
    if (images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images.first,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      );
    }

    // fallback to firstimage from common
    if (common['firstimage'] != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          common['firstimage'],
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
      );
    }

    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
    );
  }
}