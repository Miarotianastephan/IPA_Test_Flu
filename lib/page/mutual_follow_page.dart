import 'package:flutter/material.dart';

class MutualFollowPage extends StatelessWidget {
  const MutualFollowPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('互相关注')),
      body: const Center(child: Text('这里显示互相关注的用户列表')),
    );
  }
}
