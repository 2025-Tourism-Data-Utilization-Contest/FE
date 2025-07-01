import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String reviewThumbnail;
  final String reviewDate;
  final String reviewText;

  const ReviewCard({
    super.key,
    required this.reviewThumbnail,
    required this.reviewDate,
    required this.reviewText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              reviewThumbnail.isEmpty
                  ? 'assets/images/default_thumb.jpg'
                  : reviewThumbnail,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  reviewDate,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 14),
                Text(
                  reviewText,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}