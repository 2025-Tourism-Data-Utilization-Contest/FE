import 'dart:ui';
import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  final String title;                 // 카드 타이틀
  final List<String> paragraphs;      // 본문 문단 리스트
  final List<Color>? gradientColors;  // 커스텀 그라디언트(옵션)
  final bool frosted;                 // 유리(블러) 효과 여부
  final EdgeInsets margin;            // 바깥 여백
  final EdgeInsets padding;           // 안쪽 여백

  const HighlightCard({
    super.key,
    required this.title,
    required this.paragraphs,
    this.gradientColors,
    this.frosted = false,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 18),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ??
        const [Color(0xFFF7D7FF), Color(0xFFFDE2C2), Color(0xFFC9F7E3)];

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...paragraphs.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              p,
              style: const TextStyle(fontSize: 14.5, height: 1.5, color: Colors.black87),
            ),
          )),
        ],
      ),
    );

    // frosted=true면 유리감 추가
    if (!frosted) return RepaintBoundary(child: card);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            card,
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
