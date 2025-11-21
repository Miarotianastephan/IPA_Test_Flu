import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isEditing;
  final FormFieldSetter<String> onSaved;
  final int maxLines;
  final TextInputType keyboardType;

  const TextFieldWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.isEditing,
    required this.onSaved,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isEditing) {
      return TextFormField(
        initialValue: value,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
        onSaved: onSaved,
      );
    } else {
      return ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value.isNotEmpty ? value : 'Non renseigné'),
      );
    }
  }
}
