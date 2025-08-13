import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinBoxes extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  /// true면 입력되는 문자를 즉시 대문자로 정규화합니다. (기본값: true)
  final bool uppercase;

  const PinBoxes({
    super.key,
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.focusNode,
    this.uppercase = true,
  });

  @override
  State<PinBoxes> createState() => _PinBoxesState();
}

class _PinBoxesState extends State<PinBoxes> {
  late final FocusNode _focus = widget.focusNode ?? FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    widget.controller.addListener(_handleChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleChange);
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  void _handleChange() {
    // 영문/숫자만 남기고(포매터가 필터하지만 혹시 몰라 2차 방어), 대소문자 정규화
    String raw = widget.controller.text;
    final filtered = raw.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    final normalized = widget.uppercase ? filtered.toUpperCase() : filtered;
    if (raw != normalized) {
      // 커서 끝 유지
      widget.controller.value = TextEditingValue(
        text: normalized.substring(0, normalized.length.clamp(0, widget.length)),
        selection: TextSelection.collapsed(
          offset: normalized.length.clamp(0, widget.length),
        ),
      );
    }
    setState(() {}); // 박스 UI 갱신
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Column(
        children: [
          // 숨겨진 실제 입력기
          Offstage(
            offstage: true,
            child: TextField(
              focusNode: _focus,
              controller: widget.controller,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              // 영문/숫자만 허용 + 길이 제한
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(widget.length),
              ],
            ),
          ),
          // 박스 렌더링
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (i) {
              final filled = i < code.length;
              final char = filled ? code[i] : "";
              return Container(
                width: 40,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: filled
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black12,
                  ),
                ),
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
