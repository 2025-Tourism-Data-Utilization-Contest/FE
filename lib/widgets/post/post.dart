import 'package:showings/settings/comment.dart';
import 'package:showings/settings/user.dart';
import 'package:showings/settings/travel_course.dart';

enum PostType {
  normal,     // 일반 게시글 (사진 + 텍스트)
  poll,       // 투표형 게시글
}

class Post {
  // 공통 필드
  final String id;
  final User user;
  final DateTime createdAt;
  final PostType type;

  // 일반 게시글용
  final String? content;
  int? likeCount;
  int? commentCount;
  List<Comment>? comments;
  Map<User, bool>? likes;
  List<String>? tags;
  final List<String>? imageUrls;

  // 투표 게시글용
  final String? title;
  int? voteCount;
  Map<TravelCourse, int>? courseTovote;
  final DateTime? startDate;  // ✅ 여행 시작일
  final DateTime? endDate;    // ✅ 여행 종료일

  Post({
    required this.id,
    required this.user,
    required this.createdAt,
    required this.type,
    this.content = "",
    this.likeCount = 0,
    this.commentCount = 0,
    this.tags,
    this.imageUrls,
    this.title,
    this.voteCount,
    this.courseTovote,
    this.startDate,  // ✅ 추가
    this.endDate,    // ✅ 추가
  });
}


