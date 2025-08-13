import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'travel_day.dart';
import 'user.dart';

const _courseCountKey = 'travel_course_count';
const _coursePrefix = 'travel_course_';

Future<void> addCourses(TravelCourse course) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = jsonEncode(course.toJson());
  int count = prefs.getInt('travel_course_count') ?? 0;

  await prefs.setString('travel_course_$count', jsonStr);
  await prefs.setInt('travel_course_count', count + 1);
}

Future<List<TravelCourse>> loadAllTravelCourses() async {
  final prefs = await SharedPreferences.getInstance();
  final count = prefs.getInt(_courseCountKey) ?? 0;

  List<TravelCourse> loaded = [];

  for (int i = 0; i < count; i++) {
    final jsonStr = prefs.getString('$_coursePrefix$i');
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr);
        loaded.add(TravelCourse.fromJson(map));
      } catch (_) {
        // 에러 무시
      }
    }
  }

  return loaded;
}

Future<void> clearAllTravelCourses() async {
  final prefs = await SharedPreferences.getInstance();
  final count = prefs.getInt(_courseCountKey) ?? 0;

  for (int i = 0; i < count; i++) {
    await prefs.remove('$_coursePrefix$i');
  }

  await prefs.remove(_courseCountKey);
}

class TravelCourse {
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<TravelDay> days;
  final User author;
  final int id;
  int? liked = 0;

  TravelCourse({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.author,
    required this.id
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TravelCourse &&
              runtimeType == other.runtimeType &&
              title == other.title &&
              startDate == other.startDate &&
              endDate == other.endDate &&
              author == other.author;

  @override
  int get hashCode =>
      title.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      author.hashCode;


  Map<String, dynamic> toJson() => {
    'title': title,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'days': days.map((d) => d.toJson()).toList(),
    'author': author.toJson(), // ✅ 포함
  };

  factory TravelCourse.fromJson(Map<String, dynamic> json) => TravelCourse(
    title: json['title'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    days: (json['days'] as List).map((d) => TravelDay.fromJson(d)).toList(),
    author: User.fromJson(json['author']), // ✅ 포함
    id: json["id"]
  );
}
