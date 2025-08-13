import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final _storage = FlutterSecureStorage();

class ThemePoint {
  final int id;
  final List<String> seasons;
  final List<String> dayTimes;
  final double x; // lat
  final double y; // lng

  ThemePoint({
    required this.id,
    required this.seasons,
    required this.dayTimes,
    required this.x,
    required this.y,
  });

  factory ThemePoint.fromJson(Map<String, dynamic> j) => ThemePoint(
    id: j['id'] as int,
    seasons: (j['seasons'] as List).cast<String>(),
    dayTimes: (j['dayTimes'] as List).cast<String>(),
    x: (j['locationX'] as num).toDouble(),
    y: (j['locationY'] as num).toDouble(),
  );
}

Future<String> _getAccessToken() async {
  final token = await _storage.read(key: 'accessToken');
  if (token == null) throw Exception("엑세스 토큰이 없습니다.");
  return token;
}

Future<Map<String, String>> _getAuthHeaders({bool isJson = false}) async {
  final token = await _getAccessToken();
  return {
    if (isJson) 'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}

class ThemeService {
  // 배열 쿼리를 안전하게 붙이기 위한 helper
  static String _buildMultiQuery({
    required List<String> seasons,
    required List<String> dayTimes,
  }) {
    final parts = <String>[];
    for (final s in seasons) {
      parts.add('seasons=${Uri.encodeQueryComponent(s)}');
    }
    for (final d in dayTimes) {
      parts.add('dayTimes=${Uri.encodeQueryComponent(d)}');
    }
    return parts.join('&');
  }

  static Future<List<ThemePoint>> fetchThemes({
    required List<String> seasons,
    required List<String> dayTimes,
  }) async {
    final headers = await _getAuthHeaders();
    final query = _buildMultiQuery(seasons: seasons, dayTimes: dayTimes);
    final uri = Uri.parse(
        'https://api.saeroksaerok.site/api/v1/theme${query.isNotEmpty ? '?$query' : ''}');

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('테마 가져오기 실패: ${res.body}');
    }
    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (obj['data'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => ThemePoint.fromJson(e)).toList();
  }
}


// ===== Detail Models =====
class ThemeDescriptionBlock {
  final String title;
  final String description;
  ThemeDescriptionBlock({required this.title, required this.description});

  factory ThemeDescriptionBlock.fromJson(Map<String, dynamic> j) =>
      ThemeDescriptionBlock(
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
      );
}

class BirdRef {
  final int id;
  final String name;
  BirdRef({required this.id, required this.name});

  factory BirdRef.fromJson(Map<String, dynamic> j) =>
      BirdRef(id: (j['id'] as num).toInt(), name: (j['name'] ?? '') as String);
}

class PlaceRef {
  final int id;
  final String title;
  final String placeImage;
  PlaceRef({required this.id, required this.title, required this.placeImage});

  factory PlaceRef.fromJson(Map<String, dynamic> j) => PlaceRef(
    id: (j['id'] as num).toInt(),
    title: (j['title'] ?? '') as String,
    placeImage: (j['placeImage'] ?? '') as String,
  );
}

class ExperiencePlaceRef extends PlaceRef {
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final int? price;

  ExperiencePlaceRef({
    required super.id,
    required super.title,
    required super.placeImage,
    this.availableFrom,
    this.availableTo,
    this.price,
  });

  factory ExperiencePlaceRef.fromJson(Map<String, dynamic> j) => ExperiencePlaceRef(
    id: (j['id'] as num).toInt(),
    title: (j['title'] ?? '') as String,
    placeImage: (j['placeImage'] ?? '') as String,
    availableFrom: (j['availableFrom'] != null && (j['availableFrom'] as String).isNotEmpty)
        ? DateTime.tryParse(j['availableFrom'])
        : null,
    availableTo: (j['availableTo'] != null && (j['availableTo'] as String).isNotEmpty)
        ? DateTime.tryParse(j['availableTo'])
        : null,
    price: (j['price'] as num?)?.toInt(),
  );
}

class ReviewRef {
  final int id;
  final String comment;
  ReviewRef({required this.id, required this.comment});

  factory ReviewRef.fromJson(Map<String, dynamic> j) =>
      ReviewRef(id: (j['id'] as num).toInt(), comment: (j['comment'] ?? '') as String);
}

class ThemeDetail {
  final int id;
  final String title;
  final String themeImage;
  final String address;
  final String locationIntro;
  final List<String> highlightPoints;
  final List<ThemeDescriptionBlock> descriptionBlocks;
  final List<BirdRef> birds;
  final List<PlaceRef> attractionPlaces;
  final List<ExperiencePlaceRef> experiencePlaces;
  final int reviewCount;
  final List<ReviewRef> reviews;

  ThemeDetail({
    required this.id,
    required this.title,
    required this.themeImage,
    required this.address,
    required this.locationIntro,
    required this.highlightPoints,
    required this.descriptionBlocks,
    required this.birds,
    required this.attractionPlaces,
    required this.experiencePlaces,
    required this.reviewCount,
    required this.reviews,
  });

  factory ThemeDetail.fromJson(Map<String, dynamic> j) => ThemeDetail(
    id: (j['id'] as num).toInt(),
    title: (j['title'] ?? '') as String,
    themeImage: (j['themeImage'] ?? '') as String,
    address: (j['address'] ?? '') as String,
    locationIntro: (j['locationIntro'] ?? '') as String,
    highlightPoints: ((j['highlightPoints'] as List?) ?? const [])
        .map((e) => e.toString())
        .toList(),
    descriptionBlocks: ((j['descriptionBlocks'] as List?) ?? const [])
        .map((e) => ThemeDescriptionBlock.fromJson(e as Map<String, dynamic>))
        .toList(),
    birds: ((j['birds'] as List?) ?? const [])
        .map((e) => BirdRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    attractionPlaces: ((j['attractionPlaces'] as List?) ?? const [])
        .map((e) => PlaceRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    experiencePlaces: ((j['experiencePlaces'] as List?) ?? const [])
        .map((e) => ExperiencePlaceRef.fromJson(e as Map<String, dynamic>))
        .toList(),
    reviewCount: (j['reviewCount'] as num? ?? 0).toInt(),
    reviews: ((j['reviews'] as List?) ?? const [])
        .map((e) => ReviewRef.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

// ===== Detail API =====
extension ThemeDetailApi on ThemeService {
  static Future<ThemeDetail> fetchThemeDetail(int themeId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('https://api.saeroksaerok.site/api/v1/theme/$themeId');

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('단건 테마 조회 실패: ${res.body}');
    }
    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    final data = obj['data'] as Map<String, dynamic>;
    return ThemeDetail.fromJson(data);
  }

  static Future<void> fetchBirdDetail(int birdId) async {
    final headers = await _getAuthHeaders();
    final uri = Uri.parse('https://api.saeroksaerok.site/api/v1/bird/$birdId');

    final res = await http.get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('새 조회 실패: ${res.body}');
    }
    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    final data = obj['data'] as Map<String, dynamic>;
    print("새 정보 : $data");
  }
}

