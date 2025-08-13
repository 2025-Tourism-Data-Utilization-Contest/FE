import 'package:flutter/material.dart';
import 'package:showings/settings/call_api.dart';
import 'package:showings/screens/detail_views/lodging.dart';
import 'package:showings/screens/detail_views/default.dart';
import 'package:showings/screens/detail_views/toure_spot.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String title;
  final String contentId;
  final String contentTypeId;
  final String address;

  const PlaceDetailScreen({
    super.key,
    required this.title,
    required this.contentId,
    required this.contentTypeId,
    required this.address,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlaceDetail();
  }

  Future<void> fetchPlaceDetail() async {
    try {
      final data = await getPlaceDetail(
        contentId: widget.contentId,
        contentTypeId: widget.contentTypeId,
      );
      setState(() {
        detailData = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ 상세 정보 API 호출 오류: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 타입에 따라 다른 UI
    switch (widget.contentTypeId) {
      case "32": // 숙박
        return LodgingDetailView(data: detailData!);
      case "12":
        return TouristSpotDetailView(data: detailData!);
      case "28":
        return TouristSpotDetailView(data: detailData!);
      case "14":
        return TouristSpotDetailView(data: detailData!);
      case "38":
        return TouristSpotDetailView(data: detailData!);
      case "39": // 음식점
        return TouristSpotDetailView(data: detailData!);
      case "15": // 축제
        return TouristSpotDetailView(data: detailData!);
      default:
        return DefaultDetailView(data: detailData!);
    }
  }
}
