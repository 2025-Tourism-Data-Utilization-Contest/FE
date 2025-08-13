import 'dart:io';
import 'package:flutter/material.dart';
import 'package:showings/widgets/post/post.dart';
import 'package:showings/settings/travel_course.dart';

class PollPostCard extends StatefulWidget {
  final Post post;

  const PollPostCard({super.key, required this.post});

  @override
  State<PollPostCard> createState() => _PollPostCardState();
}

class _PollPostCardState extends State<PollPostCard> {
  late Map<TravelCourse, int> _courseVotes;

  @override
  void initState() {
    super.initState();
    _courseVotes = Map.from(widget.post.courseTovote ?? {});
  }

  void _addCourse(TravelCourse course) {
    if (_courseVotes.containsKey(course)) return;

    setState(() {
      _courseVotes[course] = 0;
      widget.post.courseTovote = _courseVotes; // 🔥 post 객체에도 반영
    });
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16), // ✅ 전체에 일괄 padding 적용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 유저 정보
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getColorFromName(widget.post.user.name),
                  backgroundImage: _resolveUserImage(widget.post.user.profileImageUrl),
                  child: _resolveUserImage(widget.post.user.profileImageUrl) == null
                      ? Text(widget.post.user.name.characters.first)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.post.user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 16),

            // 2. 투표 정보 박스
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE3FAE9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "투표 중",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.post.title ?? "제목 없음",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_formatDate(widget.post.startDate)} ~ ${_formatDate(widget.post.endDate)}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. 하단 탭 영역
            Row(
              children: [
                _tabItem("현재 후보", 0),
                _tabItem("투표 현황", 0),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  label: const Text("인기 순"),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    textStyle: const TextStyle(fontSize: 14),
                    foregroundColor: Colors.black87, // 아이콘/텍스트 색
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_courseVotes.isNotEmpty) ...[
              const Text("후보 일정", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._courseVotes.entries.map((entry) => _buildCourseVoteCard(entry.key, entry.value)),
              const SizedBox(height: 16),
            ],
            // 4. 일정 추가 버튼
            GestureDetector(
              onTap: () {
                _showCoursePickerDialog(context, (selectedCourse) {
                  _addCourse(selectedCourse); // ✅ 상태 갱신
                });
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 28, color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text('$label $count', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(height: 2, width: 60, color: Colors.black87),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.month}월 ${date.day}일(${_getWeekdayKor(date.weekday)})";
  }

  String _getWeekdayKor(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }

  Color _getColorFromName(String name) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.orange,
    ];
    final hash = name.codeUnits.reduce((a, b) => a + b);
    return colors[hash % colors.length];
  }
}

ImageProvider? _resolveUserImage(String? path) {
  if (path == null || path.isEmpty) return null;

  final file = File(path);
  if (file.existsSync()) {
    return FileImage(file);
  }

  if (path.startsWith('http') || path.startsWith('https')) {
    return NetworkImage(path);
  }

  return null;
}

Future<void> _showCoursePickerDialog(BuildContext context, void Function(TravelCourse) onCourseSelected) async {
  final courses = await loadAllTravelCourses();

  if (courses.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장된 일정이 없습니다')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('후보 추가'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final user = course.author;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onCourseSelected(course);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 프로필 이미지 (로컬 or 네트워크)
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: _resolveUserImage(user.profileImageUrl),
                          backgroundColor: Colors.grey[300],
                          child: _resolveUserImage(user.profileImageUrl) == null
                              ? Text(user.name.characters.first)
                              : null,
                        ),
                        const SizedBox(width: 12),

                        // 일정 정보
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${course.startDate.month}/${course.startDate.day} ~ ${course.endDate.month}/${course.endDate.day}",
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: const TextStyle(fontSize: 12, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _buildCourseVoteCard(TravelCourse course, int voteCount) {
  final user = course.author;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8F8F8),
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: _getColorFromName(user.name),
              backgroundImage: _resolveUserImage(user.profileImageUrl),
              child: _resolveUserImage(user.profileImageUrl) == null
                  ? Text(user.name.characters.first)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(course.title, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.blue),
            const SizedBox(width: 4),
            Text('$voteCount', style: const TextStyle(color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: course.days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final placeTitles = day.places.map((p) => p.name).join(', ');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(
                      text: "Day ${index + 1} ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: placeTitles),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

Color _getColorFromName(String name) {
  final colors = [
    Colors.indigo,
    Colors.pink,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.deepPurple,
    Colors.teal,
    Colors.blueGrey,
    Colors.lightBlue,
    Colors.amber,
  ];
  final hash = name.codeUnits.reduce((a, b) => a + b);
  return colors[hash % colors.length];
}


