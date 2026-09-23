import 'package:flutter/material.dart';

/// 跨 feature 共用的可清空输入框（workspace 的仓库配置、commits 的搜索/分支/条数、tags 的搜索都在用）。
class ClearableTextField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String label;
  final String? placeholder;
  final int minLines;

  const ClearableTextField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.placeholder,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _FieldController(value),
      onChanged: onChanged,
      minLines: minLines,
      maxLines: minLines <= 1 ? 1 : 8,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: value.isEmpty
            ? null
            : IconButton(icon: const Text('×'), onPressed: () => onChanged('')),
      ),
    );
  }
}

/// 轻量受控输入：每次 value 变化重建 controller 并保持光标在末尾
class _FieldController extends TextEditingController {
  _FieldController(String text) {
    this.text = text;
    selection = TextSelection.collapsed(offset: this.text.length);
  }
}
