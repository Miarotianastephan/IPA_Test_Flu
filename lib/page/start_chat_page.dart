import 'package:flutter/material.dart';

class StartChatPage extends StatefulWidget {
  const StartChatPage({super.key});

  @override
  State<StartChatPage> createState() => _StartChatPageState();
}

class _StartChatPageState extends State<StartChatPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发起对话'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '请输入用户名或ID',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Mocked number of search results
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('用户$index'),
                  subtitle: const Text('搜索结果占位符'),
                  onTap: () {
                    // TODO: implement selecting user to start chat
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}