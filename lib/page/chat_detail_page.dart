import 'package:flutter/material.dart';

class ChatDetailPage extends StatelessWidget {
  final int userId;
  const ChatDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天 - 用户 $userId'),
      ),
      body: Center(
        child: Text('这里是与用户 $userId 的聊天详情页'),
      ),
    );
  }
}