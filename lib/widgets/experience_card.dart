import 'package:flutter/material.dart';
import 'package:showings/widgets/review_card.dart';

class ExperienceCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String period;
  final String price;
  final String reviewCount;
  final String reviewDate;
  final String reviewText;
  final String reviewThumbnail;

  const ExperienceCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.period,
    required this.price,
    required this.reviewCount,
    required this.reviewDate,
    required this.reviewText,
    required this.reviewThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imagePath.startsWith('http')
                ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            )
                : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          const SizedBox(height: 12),

          // 제목
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          // 기간
          Text(
            period,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 4),

          // 가격
          Text(
            price,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // 리뷰 줄
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(left: 10), // ← 여기 값으로 조절 (예: 4~8)
          //       child: Text.rich(
          //         TextSpan(
          //           text: '리뷰 ',
          //           style: const TextStyle(fontSize: 18, color: Colors.black87),
          //           children: [
          //             TextSpan(
          //               text: reviewCount,
          //               style: const TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     Row(
          //       children: [
          //         Text('전체보기',
          //             style: TextStyle(color: Colors.black, fontSize: 16)),
          //         const SizedBox(width: 4),
          //         const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black54),
          //       ],
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 12),

          // 리뷰 카드
          // SingleChildScrollView(
          //   scrollDirection: Axis.horizontal,
          //   child: Row(
          //     children: List.generate(5, (index) {
          //       return Padding(
          //         padding: const EdgeInsets.only(right: 12),
          //         child: ReviewCard(
          //           reviewThumbnail: reviewThumbnail,
          //           reviewDate: reviewDate,
          //           reviewText: reviewText,
          //         ),
          //       );
          //     }),
          //   ),
          // ),
        ],
      ),
    );
  }
}
