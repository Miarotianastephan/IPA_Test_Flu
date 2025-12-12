import 'package:flutter/services.dart';

class UsernameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    if (RegExp(r'[\s!#$%^&*()\-+=\[\]{};:",.<>?/\\|`~]').hasMatch(newText)) {
      return oldValue;
    }

    final underscoreCount = '_'.allMatches(newText).length;
    final atCount = '@'.allMatches(newText).length;

    if (underscoreCount > 1 || atCount > 1) {
      return oldValue;
    }

    return newValue;
  }
}
