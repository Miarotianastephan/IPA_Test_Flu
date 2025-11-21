import 'package:flutter/material.dart';

class SaveButtonEditUser extends StatelessWidget {
  final VoidCallback onPressed;

  const SaveButtonEditUser({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.onSecondary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: const Text("Save", style: TextStyle(fontSize: 18)),
    );
  }
}
