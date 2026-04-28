import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/phone_number_formatter.dart';

class TextFieldWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    List<TextInputFormatter>? getInputFormatters() {
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
        inputFormatters: getInputFormatters(),
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
                    return i18n.translate('phoneNumberTooShort');
                  }
                  if (digitsOnly.length > 15) {
                    return i18n.translate('phoneNumberTooLong');
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
          value.isNotEmpty ? value : i18n.translate('notProvided'),
        ),
      );
    }
  }
}
