import 'package:flutter/material.dart';
import 'package:showings/screens/pin_boxes.dart';
import 'package:showings/settings/call_api.dart';
import 'package:showings/widgets/post/post_button.dart';
import 'team_flow_config.dart';

class TeamUpsertPage extends StatefulWidget {
  final TeamMode mode;
  const TeamUpsertPage({super.key, required this.mode});

  @override
  State<TeamUpsertPage> createState() => _TeamUpsertPageState();
}

class _TeamUpsertPageState extends State<TeamUpsertPage> {
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _codeFocus = FocusNode();

  late final TeamFlowConfig _cfg = TeamFlowConfig.fromMode(widget.mode);

  int _step = 0;            // 0: 이름, 1: 코드
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _nameFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _submit() async {
    if (_loading) return;

    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _snack("팀 이름을 입력해 주세요");
        _nameFocus.requestFocus();
        return;
      }
      setState(() => _step = 1);
      await Future.delayed(const Duration(milliseconds: 60));
      _codeFocus.requestFocus();
      return;
    }

    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();

    if (code.isEmpty || (_cfg.usePinBoxesForCode && code.length != 6)) {
      _snack(_cfg.usePinBoxesForCode ? "6자리 입장코드를 입력해 주세요" : "비밀번호를 입력해 주세요");
      _codeFocus.requestFocus();
      return;
    }

    setState(() => _loading = true);
    try {
      if (widget.mode == TeamMode.create) {
        await TeamService.createTeam(name, code);
      } else {
        await TeamService.joinTeam(name, code);
      }
      if (!mounted) return;
      FabOverlayManager.showAgain();
      Navigator.pop(context, true);
    } catch (e) {
      _snack('❌ 처리 실패: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _canTap {
    if (_loading) return false;
    if (_step == 0) return _nameCtrl.text.trim().isNotEmpty;
    if (_cfg.usePinBoxesForCode) return _codeCtrl.text.trim().length == 6;
    return _codeCtrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isStep1 = _step == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // 뒤로가기 버튼 색
        leading: isStep1
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _step = 0),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
          SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            24,
            isStep1 ? 80 : 60, // 👈 단계별로 살짝 내림
            24,
            120 + bottomInset,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isStep1 ? _buildStep1(theme) : _buildStep2(theme),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  backgroundColor: _canTap
                      ? Colors.green
                      : Colors.grey.shade300,
                  foregroundColor: _canTap
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
                onPressed: _canTap ? _submit : null,
                child: _loading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(isStep1 ? _cfg.confirmLabelStep1 : _cfg.confirmLabelStep2),
              ),
            ),
          ),
        ),
          ],
        ),
      ),
    );
  }

  // ------- UI blocks -------
  Widget _titleAndHelper(ThemeData theme, String title, String helper) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          helper,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Column(
      key: const ValueKey('step-name'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleAndHelper(theme, _cfg.step1Title, _cfg.step1Helper),
        const SizedBox(height: 48),
        TextField(
          controller: _nameCtrl,
          focusNode: _nameFocus,
          maxLength: 20,
          decoration: InputDecoration(
            hintText: _cfg.nameHint,
            counterText: "",
            border: const UnderlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${_nameCtrl.text.length}/20",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Column(
      key: const ValueKey('step-code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titleAndHelper(theme, _cfg.step2Title, _cfg.step2Helper),
        const SizedBox(height: 48),
        _cfg.usePinBoxesForCode
            ? PinBoxes(
          controller: _codeCtrl,
          length: 6,
          onChanged: (_) => setState(() {}),
          focusNode: _codeFocus,
        )
            : TextField(
          controller: _codeCtrl,
          focusNode: _codeFocus,
          obscureText: true,
          decoration: InputDecoration(
            hintText: _cfg.codeHint,
            border: const UnderlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
