import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/utils/phone_number_formatter.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isEditing;
  final FormFieldSetter<String> onSaved;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.isEditing,
    required this.onSaved,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    List<TextInputFormatter>? _getInputFormatters() {
      if (inputFormatters != null) {
        return [...inputFormatters!, LengthLimitingTextInputFormatter(16)];
      }
      if (keyboardType == TextInputType.number) {
        return [PhoneNumberFormatter(), LengthLimitingTextInputFormatter(16)];
      }
      return null;
    }

    if (isEditing) {
      return TextFormField(
        initialValue: value,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: _getInputFormatters(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.onSurface,
              width: 2,
            ),
          ),
        ),
        validator: keyboardType == TextInputType.number
            ? (val) {
                if (val != null && val.isNotEmpty) {
                  final digitsOnly = val.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digitsOnly.length < 7) {
                    return localizations.phoneNumberTooShort;
                  }
                  if (digitsOnly.length > 15) {
                    return localizations.phoneNumberTooLong;
                  }
                }
                return null;
              }
            : null,
        onSaved: onSaved,
      );
    } else {
      return ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value.isNotEmpty ? value : AppLocalizations.of(context)!.notProvided,
        ),
      );
    }
  }
}
