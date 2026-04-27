import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/utils/phone_number_formatter.dart';
import 'package:live_app/widgets/html_text_field.dart';

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
      return _HtmlTextFormField(
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

class _HtmlTextFormField extends StatefulWidget {
  final String initialValue;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration decoration;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String> onSaved;

  const _HtmlTextFormField({
    required this.initialValue,
    required this.maxLines,
    required this.keyboardType,
    required this.inputFormatters,
    required this.decoration,
    required this.validator,
    required this.onSaved,
  });

  @override
  State<_HtmlTextFormField> createState() => _HtmlTextFormFieldState();
}

class _HtmlTextFormFieldState extends State<_HtmlTextFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _HtmlTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text == oldWidget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
      builder: (field) {
        return HtmlTextField(
          controller: _controller,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          decoration: widget.decoration.copyWith(errorText: field.errorText),
          onChanged: field.didChange,
        );
      },
    );
  }
}
