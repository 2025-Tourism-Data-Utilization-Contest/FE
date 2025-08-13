import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

final _storage = FlutterSecureStorage();

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


class TeamService {
  static final _baseUrl = 'https://api.saeroksaerok.site/api/v1/post';

  static Future<void> addComment(int id, String comment) async {
    final url = Uri.parse("$_baseUrl/$id/comments");
    final headers = await _getAuthHeaders(isJson: true);

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({"comment": comment}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 댓글 생성 성공");
    } else {
      throw Exception("댓글 생성 실패: ${response.body}");
    }
  }

  static Future<void> getComments(int id) async {
    final url = Uri.parse("$_baseUrl/$id/comments");
    final headers = await _getAuthHeaders(isJson: true);

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 댓글 조회 성공");
    } else {
      throw Exception("댓글 조회 실패: ${response.body}");
    }
  }

  static Future<void> deleteComment(int postId , int commentId ) async {
    final url = Uri.parse("$_baseUrl/$postId/comments/$commentId");
    final headers = await _getAuthHeaders(isJson: true);

    final response = await http.delete(
      url,
      headers: headers,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ 댓글 삭제 성공");
    } else {
      throw Exception("댓글 삭제 실패: ${response.body}");
    }
  }
}