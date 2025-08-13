import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../settings/call_api.dart';
import '../settings/travel_course.dart';
import '../settings/user.dart';
import 'course_detail_page.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ 흰 배경
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ProfileSection(),
            SizedBox(height: 24),
            Divider(thickness: 10, color: Color(0xFFDDDDDD), height: 32), // ✅ 진한 구분선
            CourseListSection(),
            Divider(thickness: 5, color: Color(0xFFDDDDDD), height: 32),
            FaqSection(),
          ],
        ),
      ),
    );
  }
}

// ✅ 프로필 섹션
class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  late User user = User(name: '홍길동', profileImageUrl: '');
  late Map<String, dynamic> myData;
  int postCount = 0;      // ✅ 추가
  String email = '';      // ✅ 추가

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.fetchMember();
      if (!mounted) return;
      setState(() {
        myData = data;
        user = User(
          name: data['name'] ?? '홍길동',
          profileImageUrl: data['profileImage'] ?? '',
        );
        postCount = data['postCount'] ?? 0; // ✅ 게시글 수
        email = data['email'] ?? '';        // ✅ 이메일
      });
    } catch (e, st) {
      print('❌ fetchMember failed: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필 정보를 불러오지 못했습니다.')),
      );
    }
  }

  void _openEditDialog() async {
    final nameController = TextEditingController(text: user.name);
    String? newImagePath = user.profileImageUrl;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('프로필 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() => newImagePath = picked.path);
                  }
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: newImagePath != null && newImagePath!.isNotEmpty
                      ? FileImage(File(newImagePath!))
                      : null,
                  child: newImagePath == null || newImagePath!.isEmpty
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '이름'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  String? imageUrl = user.profileImageUrl;

                  if (newImagePath != user.profileImageUrl && newImagePath != null) {
                    final imageFile = File(newImagePath!);
                    final urls = await uploadImagesAndGetUrls([imageFile], 'profile');
                    imageUrl = urls.first;
                  }

                  await ProfileService.updateUserProfile(name: nameController.text, imageUrl: imageUrl);

                  final updated = User(
                    name: nameController.text,
                    profileImageUrl: imageUrl ?? '',
                  );
                  this.setState(() => user = updated);
                  Navigator.pop(context);
                } catch (e) {
                  print("❌ 프로필 업데이트 실패: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프로필 수정에 실패했습니다.')),
                  );
                }
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 기본 저장소 초기화

    final storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');

    print('🧹 로그아웃: 모든 토큰 및 사용자 정보 삭제됨');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('프로필 편집'),
                onTap: () {
                  Navigator.pop(context); // 시트 닫고
                  _openEditDialog();      // 기존 다이얼로그 실행
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('로그아웃'),
                onTap: () async {
                  Navigator.pop(context);
                  await _handleLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        user.profileImageUrl.isNotEmpty
            ? CircleAvatar(
          radius: 27,
          backgroundImage: user.profileImageUrl.startsWith('http')
              ? NetworkImage(user.profileImageUrl)
              : FileImage(File(user.profileImageUrl)) as ImageProvider,
        )
            : const CircleAvatar(
          radius: 27,
          backgroundColor: Color(0xFF00D26A),
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column( // ✅ Column으로 변경
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row( // ✅ 기존: 이름 + 게시글 (하드코딩 제거)
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  Text( // ✅ 동적으로 변경
                    '게시글 ${postCount}개',
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (email.isNotEmpty)
                Text( // ✅ 이메일 표시 (작게)
                  email,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showSettingsSheet,
        ),
      ],
    );
  }
}


class CourseListSection extends StatefulWidget {
  const CourseListSection({super.key});

  @override
  State<CourseListSection> createState() => _CourseListSectionState();
}

// ✅ 여행코스 리스트
class _CourseListSectionState extends State<CourseListSection> {
  List<TravelCourse> courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _onDeleteCourse(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('travel_course_count') ?? 0;

    // 현재 인덱스 삭제
    await prefs.remove('travel_course_$index');

    // 🔁 나머지 인덱스 땡기기
    for (int i = index + 1; i < count; i++) {
      final next = prefs.getString('travel_course_$i');
      if (next != null) {
        await prefs.setString('travel_course_${i - 1}', next);
      }
    }

    // 마지막 삭제
    await prefs.remove('travel_course_${count - 1}');
    await prefs.setInt('travel_course_count', count - 1);

    // 다시 불러오기
    _loadCourses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('코스가 삭제되었습니다.')),
    );
  }

  Future<void> _loadCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('travel_course_count') ?? 0;

    List<TravelCourse> loadedCourses = [];

    for (int i = 0; i < count; i++) {
      final jsonString = prefs.getString('travel_course_$i');
      if (jsonString != null) {
        final map = jsonDecode(jsonString);
        final course = TravelCourse.fromJson(map);
        loadedCourses.add(course);
      }
    }

    setState(() {
      courses = loadedCourses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.map_outlined, size: 18),
            SizedBox(width: 6),
            Text(
              '내 여행계획 리스트',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (courses.isEmpty)
          const Text('저장된 여행코스가 없습니다.')
        else
          Column(
            children: courses.asMap().entries.map((entry) {
              final index = entry.key;
              final course = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TravelCourseDetailScreen(
                          travelCourse: course,
                          courseIndex: index, // 💡 index 넘겨줌
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟣 프로필 + 이름/타이틀 + 삭제 아이콘
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: (course.author.profileImageUrl?.isNotEmpty ?? false)
                                  ? FileImage(File(course.author.profileImageUrl!))
                                  : null,
                              child: (course.author.profileImageUrl?.isEmpty ?? true)
                                  ? Text(
                                course.author.name.isNotEmpty ? course.author.name[0] : '?',
                                style: const TextStyle(color: Colors.black),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.author.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  Text(
                                    course.title,
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('정말 삭제할까요?'),
                                    content: const Text('이 여행 계획은 완전히 삭제됩니다.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  _onDeleteCourse(index);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 📅 날짜
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              '${DateFormat('yyyy.MM.dd').format(course.startDate)} ~ ${DateFormat('yyyy.MM.dd').format(course.endDate)}',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 📌 Day 일정 요약
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: course.days.asMap().entries.map((entry) {
                            final day = entry.key + 1;
                            final places = entry.value.places;
                            final name = places.isNotEmpty ? places.first.name : '장소 없음';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 16, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Day $day  ',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: name),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )
      ],
    );
  }
}

// ✅ 기능 버튼들 (친구들, 좋아요 등)
class ShortcutGrid extends StatelessWidget {
  const ShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final shortcuts = [
      {'icon': Icons.people, 'label': '친구들'},
      {'icon': Icons.favorite_border, 'label': '내 좋아요'},
      {'icon': Icons.bookmark_border, 'label': '저장함'},
      {'icon': Icons.image_outlined, 'label': '내 사진'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3.5,
      ),
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(item['icon'] as IconData, size: 20),
          label: Text(item['label'] as String),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        );
      },
    );
  }
}

// ✅ FAQ 섹션
class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.headset_mic_outlined),
      label: const Text('자주 묻는 질문'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
    );
  }
}

