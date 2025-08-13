import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../settings/theme_service.dart';
import 'highlightCard.dart';

class PlacePanel extends StatelessWidget {
  final bool isOpen;
  final bool loading;
  final ThemeDetail? detail;
  final VoidCallback? onPlanPressed;
  final PanelController controller;
  final void Function(double)? onPanelSlide;

  const PlacePanel({
    super.key,
    required this.isOpen,
    required this.loading,
    required this.detail,
    required this.controller,
    this.onPlanPressed,
    this.onPanelSlide,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SlidingUpPanel(
      controller: controller,
      minHeight: isOpen ? 120 : 0,
      maxHeight: size.height * 0.82,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      parallaxEnabled: false,
      snapPoint: 0.35,
      boxShadow: const [],
      onPanelSlide: onPanelSlide,
      panelBuilder: (sc) => _PanelBody(
        scrollController: sc,
        loading: loading,
        detail: detail,
        onPlanPressed: onPlanPressed,
      ),
    );
  }
}

class _PanelBody extends StatelessWidget {
  final ScrollController scrollController;
  final bool loading;
  final ThemeDetail? detail;
  final VoidCallback? onPlanPressed;

  const _PanelBody({
    required this.scrollController,
    required this.loading,
    required this.detail,
    this.onPlanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: loading
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      )
          : (detail == null)
          ? const Padding(
        padding: EdgeInsets.all(16),
        child: Text('데이터를 불러오지 못했어요.'),
      )
          : SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.only(
          bottom: 16 + MediaQuery.of(context).padding.bottom,
        ),
        child: _DetailContent(detail: detail!, onPlanPressed: onPlanPressed),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final ThemeDetail detail;
  final VoidCallback? onPlanPressed;

  const _DetailContent({required this.detail, this.onPlanPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.themeImage.isNotEmpty)
          RepaintBoundary(child: _HeaderImage(url: detail.themeImage)),

        // 타이틀
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            detail.title.isEmpty ? '테마 #${detail.id}' : detail.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),

        // 주소
        if (detail.address.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(detail.address)),
              ],
            ),
          ),
        ],

        // 한 줄 소개
        if (detail.locationIntro.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(detail.locationIntro),
          ),
        ],

        // 하이라이트
        if (detail.highlightPoints.isNotEmpty) ...[
          _section('하이라이트'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: HighlightCard(
              title: '이것만 알고 가자 💡',
              paragraphs: detail.highlightPoints,
              // gradientColors: [ ... ], // 필요 시 커스텀
              // frosted: true,          // 유리감 주고 싶으면
            ),
          ),
        ],


        // 설명 블록
        if (detail.descriptionBlocks.isNotEmpty) ...[
          _section('소개'),
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detail.descriptionBlocks.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (b.title.isNotEmpty)
                          Text(b.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        if (b.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(b.description),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],

        // 탐조 대상(새)
        if (detail.birds.isNotEmpty) ...[
          _section('탐조 대상'),
          RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detail.birds.map((b) => Chip(label: Text(b.name))).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 주변 관광지 (가로 스크롤)
        if (detail.attractionPlaces.isNotEmpty) ...[
          _section('주변 관광지'),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: detail.attractionPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = detail.attractionPlaces[i];
                return _PlaceThumbCard(title: p.title, imageUrl: p.placeImage);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        // 프로그램/체험 (builder)
        if (detail.experiencePlaces.isNotEmpty) ...[
          _section('프로그램 · 체험'),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.experiencePlaces.length,
              itemBuilder: (_, i) {
                final e = detail.experiencePlaces[i];
                final period = _formatPeriod(e.availableFrom, e.availableTo);
                final priceText = (e.price ?? 0) <= 0 ? '무료' : '${e.price}원';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExperienceRow(
                    title: e.title,
                    imageUrl: e.placeImage,
                    period: period,
                    price: priceText,
                  ),
                );
              },
            ),
          ),
        ],

        // 리뷰 (길어질 경우 builder 사용)
        if (detail.reviewCount > 0) ...[
          _section('리뷰 (${detail.reviewCount})'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.reviews.length.clamp(0, 20),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• ${detail.reviews[i].comment}'),
              ),
            ),
          ),
        ],

        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPlanPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDD70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('여행계획 만들기', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPeriod(DateTime? from, DateTime? to) {
    String fmt(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    if (from != null && to != null) return '${fmt(from)} ~ ${fmt(to)}';
    if (from != null) return '${fmt(from)} ~';
    if (to != null) return '~ ${fmt(to)}';
    return '기간 정보 없음';
  }
}

Widget _section(String t) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
  child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
);

class _HeaderImage extends StatelessWidget {
  final String url;
  const _HeaderImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: 1080,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black12),
        ),
      ),
    );
  }
}

class _PlaceThumbCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  const _PlaceThumbCard({required this.title, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isEmpty
                  ? const ColoredBox(color: Colors.black12)
                  : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                fadeInDuration: const Duration(milliseconds: 120),
                placeholder: (_, __) => const ColoredBox(color: Colors.black12),
                errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String period;
  final String price;

  const _ExperienceRow({
    required this.title,
    required this.imageUrl,
    required this.period,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 96,
            height: 64,
            child: imageUrl.isEmpty
                ? const ColoredBox(color: Colors.black12)
                : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 600,
              fadeInDuration: const Duration(milliseconds: 120),
              placeholder: (_, __) => const ColoredBox(color: Colors.black12),
              errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(period, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
