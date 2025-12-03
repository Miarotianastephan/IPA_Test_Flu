import 'dart:ui';

class InAppNotice {
  final String title;
  final String content;
  final String? avatarUrl;
  final DateTime? time;
  final VoidCallback onTap;

  InAppNotice({
    required this.title,
    required this.content,
    this.avatarUrl,
    this.time,
    required this.onTap,
  });
}