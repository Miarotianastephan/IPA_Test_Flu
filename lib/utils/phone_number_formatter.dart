import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    if (!RegExp(r'^\+?[0-9]*$').hasMatch(newText)) {
      return oldValue;
    }

    return newValue;
  }
}
