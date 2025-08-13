import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showings/widgets/post/normal_post_card.dart';
import 'package:showings/widgets/post/post.dart';
import 'package:showings/widgets/post/poll_post_card.dart';
import 'package:showings/widgets/post/post_button.dart';
import 'package:showings/screens/team_cotrol_page.dart';

import '../settings/call_api.dart';
import '../settings/user.dart';

final List<Post> myGroupPosts = [

];

final List<Post> otherPosts = [

];




class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  bool _showMyGroup = true;
  bool? hasTeam;
  OverlayEntry? _memberOverlay;
  bool _isMemberOverlayVisible = false;

  List<User> _members = [];

  void _showMemberOverlay(BuildContext context) {
    if (_isMemberOverlayVisible) return;

    _memberOverlay = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 55,
        bottom: MediaQuery.of(context).padding.bottom,
        right: 0,
        width: 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(-2, 0),
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final user = _members[index];
                final hasImage = user.profileImageUrl.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: hasImage ? Colors.transparent : _getColorFromName(user.name),
                        backgroundImage: hasImage ? NetworkImage(user.profileImageUrl) : null,
                        child: hasImage
                            ? null
                            : Text(
                          user.name.characters.first,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_memberOverlay!);
    _isMemberOverlayVisible = true;
  }

  void _hideMemberOverlay() {
    _memberOverlay?.remove();
    _memberOverlay = null;
    _isMemberOverlayVisible = false;
  }




  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasTeam = prefs.getBool('hasTeam') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final result = await TeamService.fetchTeamMembers();
      setState(() {
        _members = result;
      });
    } catch (e) {
      print('⚠️ 멤버 불러오기 실패: $e');
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FabOverlayManager.show(context,_addPost);
    });
  }

  @override
  void dispose() {
    FabOverlayManager.hide();
    super.dispose();
  }

  void _addPost(Post post) {
    setState(() {
      myGroupPosts.insert(0, post);
    });
  }

  @override
  Widget build(BuildContext context) {
    final posts = _showMyGroup ? myGroupPosts : otherPosts;

    if (hasTeam == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: hasTeam!
            ? AppBar(
          centerTitle: true,
          title: GestureDetector(
            onTap: () {
              setState(() {
                _showMyGroup = !_showMyGroup;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Text(_showMyGroup ? '우리 게시판' : '모두 게시판'),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 40,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                if (_isMemberOverlayVisible) {
                  _hideMemberOverlay();
                } else {
                  _loadMembers();
                  _showMemberOverlay(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.menu, size: 24, color: Colors.black87),
                    SizedBox(height: 2),
                    Text(
                      '멤버',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ) : null,
      body: hasTeam! ? RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 18, 16, 100),
          itemCount: posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return const SizedBox(height: 16);

            final post = posts[index - 1];
            if (post is Post) {
              // 우리 그룹
              if (post.type == PostType.poll) {
                return PollPostCard(post: post);
              } else {
                return NormalPostCard(post: post);
              }
            } else {
              // 모두 게시판 카드
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('🌐 다른 사람 게시글 #$index'),
                ),
              );
            }
          },
        ),
      ): TeamControlSection(
        onTeamCreated: () {
          setState(() {
            hasTeam = true;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }
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




