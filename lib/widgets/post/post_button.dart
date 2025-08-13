import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:showings/widgets/post/post.dart';
import 'package:showings/widgets/post/write_post_screen.dart';
import 'package:intl/intl.dart';

import '../../settings/call_api.dart';
import '../../settings/user.dart';

class FabOverlayManager {
  static OverlayEntry? _entry;
  static bool _isVisible = true;
  static void Function(Post)? _onPostCreated;

  static void show(BuildContext context, void Function(Post) onPostCreated) {
    if (_entry != null) return;

    _onPostCreated = onPostCreated;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: ExpandableFabOverlay(
          onPostCreated: _onPostCreated!,
          isVisible: _isVisible,
        ),
      ),
    );

    Overlay.of(context).insert(_entry!);
  }

  static void temporarilyHide() {
    _isVisible = false;
    _entry?.markNeedsBuild(); // rebuild overlay
  }

  static void showAgain() {
    _isVisible = true;
    _entry?.markNeedsBuild(); // rebuild overlay
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class ExpandableFabOverlay extends StatefulWidget {
  final void Function(Post post) onPostCreated;
  final bool isVisible;

  const ExpandableFabOverlay({
    super.key,
    required this.onPostCreated,
    this.isVisible = true, // ✅ 기본값 설정
  });

  @override
  State<ExpandableFabOverlay> createState() => _ExpandableFabOverlayState();
}

class _ExpandableFabOverlayState extends State<ExpandableFabOverlay> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);
  void _close() => setState(() => _isExpanded = false);

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink(); // ✅ 숨기기 처리
    final width = MediaQuery.of(context).size.width;

    return IgnorePointer(
      ignoring: false,
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (_isExpanded) ...[
              _buildMiniFab(context, Icons.article, '게시글', 0, () {
                _close();
                FabOverlayManager.temporarilyHide(); // ✅ 잠깐 숨기기

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WritePostScreen()),
                ).then((result) {
                  FabOverlayManager.showAgain(); // ✅ 다시 FAB 보이게

                  if (result != null && result is Post) {
                    widget.onPostCreated(result); // ✅ 게시글 추가
                  }
                });
              }, width),

              _buildMiniFab(context, Icons.poll, '투표', pi / 2, () {
                _close();
                FabOverlayManager.temporarilyHide();

                // ✅ 팝업 닫히고 나서 다시 FAB 보여주기
                _showPollDialog(context, (post) {
                  widget.onPostCreated(post);
                }).then((_) {
                  FabOverlayManager.showAgain(); // ✅ 항상 닫힌 후에 다시 FAB 보이게
                });
              }, width),

              _buildMiniFab(context, Icons.route, '일정', pi, () {
                _close();
                FabOverlayManager.temporarilyHide(); // ✅ 잠깐 숨기기

                // 예시로 push한다고 가정 (페이지 없으면 주석 처리 가능)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Placeholder()), // TODO: WriteScheduleScreen
                ).then((_) {
                  FabOverlayManager.showAgain(); // ✅ 다시 보이게
                });
              }, width),
            ],
            Padding(
              padding: const EdgeInsets.only(bottom: 82),
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF2DDD70),
                child: Icon(_isExpanded ? Icons.close : Icons.add, size: 28),
                onPressed: _toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniFab(
      BuildContext context,
      IconData icon,
      String label,
      double angle,
      VoidCallback onTap,
      double width,
      ) {
    final radius = 90.0;
    final dx = radius * cos(angle);
    final dy = radius * sin(angle);

    return Positioned(
      bottom: 72 + dy,
      left: (width / 2) + dx - 28,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'miniFab_$label',
            onPressed: onTap,
            // backgroundColor: Colors.white.withOpacity(0.5),
            foregroundColor: Colors.black87,
            elevation: 4,
            child: Icon(icon),
          ),
          const SizedBox(height: 6),
          Material(
            type: MaterialType.transparency,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}

Future<void> _showPollDialog(BuildContext context, void Function(Post) onPostCreated) async {
  final TextEditingController titleController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('투표 만들기'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '투표 제목'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(startDate == null
                      ? '가는 날 선택'
                      : '가는 날: ${startDate!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => startDate = picked);
                  },
                ),
                ListTile(
                  title: Text(endDate == null
                      ? '오는 날 선택'
                      : '오는 날: ${endDate!.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => endDate = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty &&
                      startDate != null &&
                      endDate != null) {
                    try {
                      final dateFormatter = DateFormat('yyyy-MM-dd');

                      await PostService.createPoll(
                        title: titleController.text.trim(),
                        startDate: dateFormatter.format(startDate!),
                        endDate: dateFormatter.format(endDate!),
                      );

                      // ✅ 서버 등록 성공 후 닫기 + UI 업데이트
                      final currentUser = await loadUser();
                      final newPost = Post(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        user: currentUser,
                        createdAt: DateTime.now(),
                        type: PostType.poll,
                        title: titleController.text,
                        startDate: startDate,
                        endDate: endDate,
                        voteCount: 0,
                        courseTovote: {},
                      );

                      Navigator.pop(context);
                      onPostCreated(newPost);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('투표 등록 실패: $e')),
                      );
                    }
                  }
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    },
  );
}

