import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TextSegment {
  final String content;
  final bool isEmoji;
  final String? emojiKey;

  TextSegment({required this.content, this.isEmoji = false, this.emojiKey});
}

class EmojiTextController extends TextEditingController {
  Map<String, String> emojiMap = {}; 

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];
    final pattern = RegExp(r'\^\*#\*[\w]+\*#\*\^');
    final textValue = text;

    int last = 0;
    final matches = pattern.allMatches(textValue);

    for (final m in matches) {
      if (m.start > last) {
        children.add(
          TextSpan(text: textValue.substring(last, m.start), style: style),
        );
      }

      final key = m.group(0)!;
      final svg = emojiMap[key];

      if (svg != null) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: SvgPicture.network(svg, width: 20, height: 20),
          ),
        );
      }

      last = m.end;
    }

    if (last < textValue.length) {
      children.add(TextSpan(text: textValue.substring(last), style: style));
    }

    return TextSpan(style: style, children: children);
  }

  void insertEmoji(String key, String url) {
    emojiMap[key] = url;
    final sel = selection;

    final start = sel.isValid && sel.start >= 0 ? sel.start : text.length;
    final end = sel.isValid && sel.end >= 0 ? sel.end : text.length;

    final newText = text.replaceRange(start, end, key);

    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + key.length),
    );
  }

  String getMessageText() {
    return text;
  }

  @override
  void clear() {
    super.clear();
    emojiMap.clear();
  }
}

class EmojiDeletionFormatter extends TextInputFormatter {
  final RegExp emojiPattern = RegExp(r'\^\*#\*[\w]+\*#\*\^'); 
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isDeleting = newValue.text.length < oldValue.text.length;
    
    if (!isDeleting) return newValue;
    
    final isSingleCharDeletion = oldValue.text.length - newValue.text.length == 1;
    
    if (!isSingleCharDeletion) {
      return newValue;
    }
    
    final oldText = oldValue.text;
    final newText = newValue.text;
    
    final diffPosition = _findDifferencePosition(oldText, newText);
    
    if (diffPosition == -1) return newValue;
    
    final emojiAtPosition = _findEmojiContainingPosition(oldText, diffPosition);
    
    if (emojiAtPosition != null) {
      final updatedText = oldText.replaceRange(
        emojiAtPosition.start, 
        emojiAtPosition.end, 
        ""
      );
      
      return TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: emojiAtPosition.start),
      );
    }
    
    return newValue;
  }
  
  int _findDifferencePosition(String oldText, String newText) {
    final minLength = math.min(oldText.length, newText.length);
    
    for (int i = 0; i < minLength; i++) {
      if (oldText.codeUnitAt(i) != newText.codeUnitAt(i)) {
        return i;
      }
    }
    if (oldText.length > newText.length) {
      return minLength;
    }
    
    return -1;
  }
  
  RegExpMatch? _findEmojiContainingPosition(String text, int position) {
    for (final match in emojiPattern.allMatches(text)) {
      if (position >= match.start && position <= match.end) {
        return match;
      }
    }
    return null;
  }
}

class EmojiCursorFormatter extends TextInputFormatter {
  final RegExp emojiPattern = RegExp(r'\^\*#\*[\w]+\*#\*\^');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final text = newValue.text;
    final cursor = newValue.selection.baseOffset;

    if (cursor < 0) return newValue;

    for (final match in emojiPattern.allMatches(text)) {
      final start = match.start;
      final end = match.end;

      if (cursor > start && cursor < end) {
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: end),
        );
      }
    }

    return newValue;
  }
}

class EmojiTextField extends StatefulWidget {
  final EmojiTextController controller;
  final String hintText;
  final TextStyle? style;
  final TextStyle? hintStyle;
  
  final FocusNode? sharedFocusNode;

  const EmojiTextField({
    super.key,
    required this.controller,
    this.sharedFocusNode,
    required this.hintText,
    this.style,
    this.hintStyle,
  });

  @override
  State<EmojiTextField> createState() => _EmojiTextFieldState();
}

class _EmojiTextFieldState extends State<EmojiTextField> {
  late FocusNode _localFocusNode; 
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    
    if (widget.sharedFocusNode != null) {
      _effectiveFocusNode = widget.sharedFocusNode!;
    } else {
      _localFocusNode = FocusNode();
      _effectiveFocusNode = _localFocusNode;
    }
  }

  @override
  void dispose() {
    if (widget.sharedFocusNode == null) {
      _localFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _effectiveFocusNode,
      maxLines: null,
      style: widget.style,
      cursorColor: Colors.white,
      inputFormatters: [EmojiDeletionFormatter(), EmojiCursorFormatter()],
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        border: InputBorder.none,
        isCollapsed: true,
      ),
    );
  }
}