import 'package:flutter/material.dart';

class PlaceCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final String description;
  final VoidCallback? onMorePressed;
  final void Function(String)? onTagPressed; // 각 태그 클릭용 콜백
  final String? selectedTag;

  const PlaceCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.description,
    this.onMorePressed,
    this.onTagPressed,
    this.selectedTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          ClipRRect(
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 180),
            ),
          ),

          const SizedBox(height: 16),

          // 태그 리스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isSelected = tag == selectedTag;
                return GestureDetector(
                  onTap: () {
                    if (onTagPressed != null) {
                      onTagPressed!(tag);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8), // 더 각지게
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 내용 크기만큼만 차지
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),


          const SizedBox(height: 16),

          // 제목 + 설명 + 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onMorePressed,
                    child: const Text("더보기"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
