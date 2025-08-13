import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:showings/settings/user.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'package:charset_converter/charset_converter.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

const int maxSizeInBytes = 5 * 1024 * 1024; // 정확히 5MB

Future<XFile> compressImage(File file, {int quality = 80}) async {
  final dir = await getTemporaryDirectory();
  final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: quality, // 0~100 (낮을수록 압축률 높음)
    format: CompressFormat.jpeg,
  );

  if (result == null) throw Exception('이미지 압축 실패');
  return result;
}




final _storage = FlutterSecureStorage();

const _serviceKey =
    'nqKvNhojjgVCA51gGkpxyqNvZuypcnxOD3jEQHIsR2aJvH7OaH7gQN4FVzWGpA8IaCmxa3/tD3yh1Jgk6OkOpA==';

class TouristService {
  static const _baseUrl =
      'https://apis.data.go.kr/B551011/KorService2/locationBasedList2';

  static Future<List<dynamic>> fetchTouristSpots({
    required double mapX,
    required double mapY,
    int radius = 3000,
    int pageNo = 1,
    int numOfRows = 5,  // <- 기본값을 5로 줄임
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'serviceKey': _serviceKey,
      'MobileOS': 'AND',
      'MobileApp': 'MyTourApp',
      '_type': 'json',
      'mapX': '$mapX',
      'mapY': '$mapY',
      'radius': '$radius',
      'arrange': 'S',
      'pageNo': '$pageNo',
      'numOfRows': '$numOfRows',
    });

    final response = await http.get(uri);
    print('🔽 Raw response:\n${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      final items = body['response']['body']['items'];
      if (items == null || items['item'] == null) return [];
      return List.from(items['item']);
    } else {
      throw Exception('API 요청 실패: ${response.statusCode}');
    }
  }
}

Future<List<Map<String, dynamic>>> getFestivalExperiences() async {
  final now = DateTime.now();
  final today = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

  final queryParams = {
    'numOfRows': '5',
    'pageNo': '1',
    'MobileOS': 'AND',
    'MobileApp': 'MyFlutterApp',
    '_type': 'json',
    'arrange': 'Q',
    'eventStartDate': today,
    'serviceKey': _serviceKey,
    'lDongRegnCd': '11', // 서울
  };

  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/searchFestival2')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final rawItem = jsonData['response']['body']['items']['item'];
    final items = rawItem is List ? rawItem : [rawItem];
    return items.cast<Map<String, dynamic>>();
  } else {
    throw Exception('API 호출 실패: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> getPlaceDetail({
  required String contentId,
  required String contentTypeId,
}) async {
  try {
    print("📌 getPlaceDetail 시작");
    final common = await _getDetailCommon(contentId, contentTypeId);
    print("✅ common 완료");

    final intro = await _getDetailIntro(contentId, contentTypeId);
    print("✅ intro 완료");

    final info = await _getDetailInfo(contentId, contentTypeId);
    print("✅ info 완료");

    final images = await _getDetailImages(contentId, contentTypeId, "Y");
    print("✅ images 완료");

    List<String> images2 = []; // 👈 기본은 빈 리스트

    // if (contentTypeId == "39") {
    //   images2 = await _getDetailImages(contentId, contentTypeId, "N");
    //   print("✅ images2 완료");
    // }

    return {
      'common': common,
      'intro': intro,
      'infoList': info,
      'images': images,
      'images2': images2,
    };
  } catch (e, stack) {
    print("❌ getPlaceDetail 예외 발생: $e");
    print("🧱 스택트레이스:\n$stack");
    rethrow;
  }
}

Future<Map<String, dynamic>> _getDetailCommon(String contentId, String contentTypeId) async {
  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/detailCommon2').replace(
    queryParameters: {
      'MobileOS': 'AND',
      'MobileApp': 'MyFlutterApp',
      '_type': 'json',
      'contentId': contentId,
      'serviceKey': _serviceKey, // ✅ 그대로 유지
    },
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final item = jsonData['response']?['body']?['items']?['item'];

    print(item);

    // ✅ 타입 확인 후 안전 반환
    if (item is Map<String, dynamic>) {
      return item;
    } else if (item is List && item.isNotEmpty && item.first is Map<String, dynamic>) {
      return item.first;
    } else {
      return {}; // 예상치 못한 구조
    }
  } else {
    throw Exception('❌ detailCommon2 API 실패: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> _getDetailIntro(String contentId, String contentTypeId) async {
  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/detailIntro2').replace(
    queryParameters: {
      'MobileOS': 'AND',
      'MobileApp': 'MyApp',
      '_type': 'json',
      'contentId': contentId,
      'contentTypeId': contentTypeId,
      'serviceKey': _serviceKey,
    },
  );

  final response = await http.get(uri);
  final jsonData = json.decode(response.body);
  final item = jsonData['response']?['body']?['items']?['item'];

  print(item);

  if (item is Map<String, dynamic>) {
    return item;
  } else if (item is List && item.isNotEmpty && item.first is Map<String, dynamic>) {
    return item.first;
  } else {
    return {};
  }
}

Future<List<Map<String, dynamic>>> _getDetailInfo(String contentId, String contentTypeId) async {
  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/detailInfo2').replace(
    queryParameters: {
      'MobileOS': 'AND',
      'MobileApp': 'MyApp',
      '_type': 'json',
      'contentId': contentId,
      'contentTypeId': contentTypeId,
      'serviceKey': _serviceKey,
    },
  );

  final response = await http.get(uri);
  final jsonData = json.decode(response.body);
  final items = jsonData['response']?['body']?['items'];

  if (items is! Map) {
    return [];
  }

  final raw = items['item'];
  print("📦 detailInfo2 raw: $raw");

  if (raw == null) return [];

  return raw is List
      ? raw.cast<Map<String, dynamic>>()
      : [raw as Map<String, dynamic>];
}

Future<List<String>> _getDetailImages(String contentId, String contentTypeId, String yn) async {
  try {
    final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/detailImage2').replace(
      queryParameters: {
        'MobileOS': 'AND',
        'MobileApp': 'MyApp',
        '_type': 'json',
        'contentId': contentId,
        'imageYN': yn,
        'serviceKey': _serviceKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      print('❌ HTTP 오류: ${response.statusCode}');
      return [];
    }

    final jsonData = json.decode(response.body);
    final responseBody = jsonData['response'];
    if (responseBody == null) {
      print('❌ response가 null');
      return [];
    }

    final body = responseBody['body'];
    print(body);
    if (body == null) {
      print('❌ body가 null');
      return [];
    }

    final items = body['items'];
    if (items == null) {
      print('❌ items가 null');
      return [];
    }

    final raw = items['item'];
    if (raw == null) {
      print('❌ item이 null');
      return [];
    }

    final imageList = raw is List ? raw : [raw];
    print(imageList);

    return imageList
        .map((item) => item['originimgurl']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  } catch (e, stackTrace) {
    print('❌ 예외 발생: $e');
    print(stackTrace);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getAccommodation() async {
  final queryParams = {
    'numOfRows': '10',
    'pageNo': '1',
    'MobileOS': 'AND',
    'MobileApp': 'MyFlutterApp',
    '_type': 'json',
    // 'arrange': 'D',
    'serviceKey': _serviceKey,
    'lDongRegnCd': '11', // 서울
  };

  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/searchStay2')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    final rawItem = jsonData['response']['body']['items']['item'];

    final items = rawItem is List ? rawItem : [rawItem];

    return items.cast<Map<String, dynamic>>();
  } else {
    throw Exception('API 호출 실패: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> getTouristSpots(String type) async {
  final queryParams = {
    'numOfRows': '10',
    'pageNo': '1',
    'MobileOS': 'AND',
    'MobileApp': 'MyFlutterApp',
    '_type': 'json',
    'arrange': 'R',
    'mapX': '126.9780',      // 서울 경도
    'mapY': '37.5665',       // 서울 위도
    'radius': '20000',        // 반경 (단위: 미터)
    'contentTypeId' : type,
    'serviceKey': _serviceKey,
    'lDongRegnCd': "11",
  };

  final uri = Uri.parse('https://apis.data.go.kr/B551011/KorService2/locationBasedList2')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    final rawItem = jsonData['response']['body']['items']['item'];
    final items = rawItem is List ? rawItem : [rawItem];

    return items.cast<Map<String, dynamic>>();
  } else {
    throw Exception('API 호출 실패: ${response.statusCode}');
  }
}

Future<List<Map<String, dynamic>>> getGreenSpots() async {
  final queryParams = {
    'numOfRows': '15',
    'pageNo': '1',
    'MobileOS': 'AND',
    'MobileApp': 'MyFlutterApp',
    '_type': 'json',
    'arrange': 'D',
    'serviceKey': _serviceKey,
    'areaCode' : '1'
  };

  final uri = Uri.parse('https://apis.data.go.kr/B551011/GreenTourService1/areaBasedList1')
      .replace(queryParameters: queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);

    final rawItem = jsonData['response']['body']['items']['item'];
    final items = rawItem is List ? rawItem : [rawItem];

    // ✅ mainimage가 null이거나 빈 문자열("")이 아닌 경우만 필터링
    final filtered = items
        .where((item) => item['mainimage'] != null && item['mainimage'].toString().trim().isNotEmpty)
        .cast<Map<String, dynamic>>()
        .toList();

    for (final item in filtered) {
      print('✅ 이미지 있는 그린스팟: ${item['title']}');
    }

    return filtered;
  } else {
    print('❌ API 호출 실패: ${response.statusCode}');
    throw Exception('API 호출 실패: ${response.statusCode}');
  }
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

class ProfileService {
  static final _storage = FlutterSecureStorage();
  static const _baseUrl = 'https://api.saeroksaerok.site/api/v1/member';

  static Future<void> updateUserProfile({
    required String name,
    required String imageUrl,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.patch(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'profileImage': imageUrl,
      }),
    );

    if (response.statusCode != 200) {
      print('프로필 업데이트 실패: ${response.statusCode} ${response.body}');
      throw Exception('프로필 업데이트');
    }

    print('프로필 업데이트 성공');
  }

  static Future<Map<String, dynamic>> fetchMember() async {
    print('[fetchMember] start'); // ✅ 진입 확인
    final url = Uri.parse('https://api.saeroksaerok.site/api/v1/member');

    Map<String, String> headers;
    try {
      headers = await _getAuthHeaders();
      print('[fetchMember] headers ready: ${headers.keys.toList()}'); // 토큰 여부는 노출 X
    } catch (e) {
      print('[fetchMember] _getAuthHeaders error: $e'); // ✅ 여기서 막히는지
      rethrow;
    }

    http.Response response;
    try {
      response = await http.get(url, headers: headers);
      print('[fetchMember] response status: ${response.statusCode}');
    } catch (e) {
      print('[fetchMember] http.get error: $e'); // 네트워크 예외
      rethrow;
    }

    // ✅ 성공/실패 모두 로깅
    print('[fetchMember] body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final data = jsonMap['data'] as Map<String, dynamic>;
      print('[fetchMember] parsed data ok');
      return data;
    } else {
      throw Exception("마이페이지 실패: ${response.statusCode} ${response.body}");
    }
  }
}

class TeamService {
  static final _baseUrl = 'https://api.saeroksaerok.site/api/v1/team';

  static Future<void> createTeam(String name, String Pw) async {
    final url = Uri.parse(_baseUrl);
    final headers = await _getAuthHeaders(isJson: true);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'name': name, 'password': Pw}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 팀 생성 성공");
    } else {
      throw Exception("팀 생성 실패: ${response.body}");
    }
  }

  static Future<void> joinTeam(String teamId, String teamPw) async {
    final url = Uri.parse('$_baseUrl/join');
    final headers = await _getAuthHeaders(isJson: true);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'name': teamId, 'password': teamPw}),
    );

    if (response.statusCode == 200) {
      print("✅ 팀 참가 성공");
    } else {
      throw Exception("팀 참가 실패: ${response.body}");
    }
  }

  static Future<List<User>> fetchTeamMembers() async {
    final url = Uri.parse('https://api.saeroksaerok.site/api/v1/team/members');
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'];
      print(data);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception("팀 멤버 가져오기 실패: ${response.body}");
    }
  }
}


class PostService {
  static final _storage = FlutterSecureStorage();
  static const _baseUrl = 'https://api.saeroksaerok.site/api/v1';

  static Future<void> createPost({
    required String title,
    required String content,
    required String postType,
    required List<String> imageUrls,
    required List<String> hashtags,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.post(
      Uri.parse("$_baseUrl/post"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'postType': postType,
        'content': content,
        'imageUrls': imageUrls,
        'hashtags': hashtags,
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 게시글 등록 실패: ${response.statusCode} ${response.body}');
      throw Exception('게시글 등록 실패');
    }

    print('✅ 게시글 등록 성공');
  }

  static Future<void> createPoll({
    required String title,
    required String startDate,
    required String endDate,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.post(
      Uri.parse("$_baseUrl/poll"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        "pollStatus": "ONGOING",
        'startDate': startDate,
        'endDate': endDate,
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 투표 등록 실패: ${response.statusCode} ${response.body}');
      throw Exception('투표 등록 실패');
    }

    print('✅ 투표 등록 성공');
  }

  static Future<void> addLike({
    required int targetId,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.post(
      Uri.parse("$_baseUrl/likes"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "targetId": targetId,
        "likeTargetType": "POST"
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 좋아요 실패: ${response.statusCode} ${response.body}');
      throw Exception('좋아요 실패');
    }

    print('✅ 좋아요 성공');
  }
}

Future<List<String>> uploadImagesAndGetUrls(List<File> images, String end) async {
  final uri = Uri.parse('https://api.saeroksaerok.site/api/v1/file/$end');
  final request = http.MultipartRequest('POST', uri);

  final accessToken = await _storage.read(key: 'accessToken');
  if (accessToken == null) {
    throw Exception('엑세스 토큰이 없습니다.');
  }

  for (final file in images) {
    final compressed = await compressImage(file, quality: 70); // 품질 조절 가능
    final size = await compressed.length();

    if (size > maxSizeInBytes) {
      throw Exception('압축 후에도 5MB 초과: ${compressed.path}');
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'multipartFile',
        compressed.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

  request.headers['Authorization'] = 'Bearer $accessToken';

  final response = await request.send();
  final responseBody = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    final json = jsonDecode(responseBody);
    final List<dynamic> data = json['data'];
    final urls = data.map((e) => e['fileUrl'].toString()).toList();
    return urls;
  } else {
    print('❌ 업로드 실패 응답: $responseBody');
    throw Exception('이미지 업로드 실패: ${response.statusCode}');
  }
}

class RouteService {
  static final _storage = FlutterSecureStorage();
  static const _baseUrl = 'https://api.saeroksaerok.site/api/v1';

  static Future<Map<String, dynamic>> createRoute({
    required String startDate,
    required String endDate,
    String title = "test",
    int peopleCount = 15,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final res = await http.post(
      Uri.parse("$_baseUrl/route"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "title": title,
        "startDate": startDate,
        "endDate": endDate,
        "peopleCount": peopleCount
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      print('❌ 루트 등록 실패: ${res.statusCode} ${res.body}');
      throw Exception('루트 등록 실패');
    }

    final data = jsonDecode(res.body);
    print('✅ 루트 등록 성공: $data');
    return data; // 필요하면 호출부에서 사용
  }


  static Future<void> addPlace({
    required int routeId,
    required int dayNumber,
    required int orderInDay,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.post(
      Uri.parse("$_baseUrl/route/$routeId/places"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "placeId": 1,
        "dayNumber": dayNumber,
        "orderInDay": orderInDay,
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 장소 등록 실패: ${response.statusCode} ${response.body}');
      throw Exception('장소 등록 실패');
    }

    final data = jsonDecode(response.body);
    print('✅ 장소 등록 성공: $data');
  }

  static Future<void> removePlace({
    required int routeId,
    required int routePlaceId ,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.delete(
      Uri.parse("$_baseUrl/route/$routeId/places/$routePlaceId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "routeId": routeId,
        "routePlaceId": routePlaceId,
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 장소 삭제 실패: ${response.statusCode} ${response.body}');
      throw Exception('장소 삭제 실패');
    }

    final data = jsonDecode(response.body);
    print('✅ 장소 삭제 성공: $data');
  }

  static Future<void> editPlace({
    required int routeId,
    required int routePlaceId,
    required int dayNumber,
    required int orderInDay,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) throw Exception("엑세스 토큰이 없습니다.");

    final response = await http.patch(
      Uri.parse("$_baseUrl/route/$routeId/places/$routePlaceId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "dayNumber": dayNumber,
        "orderInDay": orderInDay
      }),
    );

    if (response.statusCode != 200) {
      print('❌ 장소 수정 실패: ${response.statusCode} ${response.body}');
      throw Exception('장소 수정 실패');
    }

    final data = jsonDecode(response.body);
    print('✅ 장소 수정 성공: $data');
  }
}



