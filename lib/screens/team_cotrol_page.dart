import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showings/screens/team_flow_config.dart';
import 'team_upsert_page.dart';
import '../widgets/post/post_button.dart';

class TeamControlSection extends StatefulWidget {
  final VoidCallback onTeamCreated;
  final Color createButtonColor;
  final Color joinButtonColor;

  const TeamControlSection({
    super.key,
    required this.onTeamCreated,
    this.createButtonColor = const Color(0xFF22C55E), // 기본 초록
    this.joinButtonColor = const Color(0xFF9CA3AF),   // 기본 회색
  });

  @override
  State<TeamControlSection> createState() => _TeamControlSectionState();
}

class _TeamControlSectionState extends State<TeamControlSection> {
  bool _hasTeam = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FabOverlayManager.temporarilyHide();
    });
    _loadHasTeam();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadHasTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final has = prefs.getBool('hasTeam') ?? false;
    setState(() => _hasTeam = has);
    if (has) FabOverlayManager.showAgain();
  }

  Future<void> _open(TeamMode mode) async {
    FabOverlayManager.temporarilyHide();

    bool ok = false;
    try {
      ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TeamUpsertPage(mode: mode)),
      ) ??
          false;

      if (ok) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasTeam', true);
        if (!mounted) return;
        setState(() => _hasTeam = true);
        widget.onTeamCreated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mode == TeamMode.create
                  ? '✅ 팀이 성공적으로 생성되었습니다!'
                  : '✅ 팀에 성공적으로 참가했습니다!',
            ),
          ),
        );
      }
    } finally {
      // FabOverlayManager.showAgain();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasTeam) {
      return const Center(
        child: Text("이미 팀에 가입되어 있습니다.", style: TextStyle(fontSize: 18)),
      );
    }

    final theme = Theme.of(context);

    return SafeArea(
      child: Stack(
        children: [
          /// ✅ 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/make_group.png',
              fit: BoxFit.cover,
            ),
          ),

          /// 상단 타이틀 (조금 아래로)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 96, 24, 0), // ⬅ top 96
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Text(
                  "사진으로 담고, 여행으로 나누는\n우리의 탐조 이야기",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),

          /// 하단 텍스트 + 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "아직 내가 속한 그룹이 없어요",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 84),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.createButtonColor,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _open(TeamMode.create),
                        child: const Text("그룹 만들기"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.joinButtonColor,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => _open(TeamMode.join),
                        child: const Text("그룹 가입하기"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
