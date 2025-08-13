import 'package:showings/settings/user.dart';

class Comment {
  final String id;
  final User user;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });
}
