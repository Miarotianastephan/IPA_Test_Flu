import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/page_params.dart';
import '../../provider/api_provider.dart';


/// 测试页
class ForumTabPage extends ConsumerStatefulWidget {
  const ForumTabPage({super.key});

  @override
  ConsumerState<ForumTabPage> createState() => _ForumTabPageState();
}

class _ForumTabPageState extends ConsumerState<ForumTabPage> {
  String _result = "";
  bool _loading = false;

  /// 调用通用测试函数
  Future<void> _run(String title, Future<dynamic> Function() action) async {
    setState(() {
      _loading = true;
      _result = "▶️ 正在调用：$title...\n";
    });

    try {
      final data = await action();
      _append("✅ [$title] 成功\n结果: $data");
    } catch (e, st) {
      _append("❌ [$title] 出错: $e\n$st");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _append(String text) {
    setState(() => _result = "$text\n");
    debugPrint(text);
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(forumServiceProvider);

    final buttons = [
      _buildBtn("分类列表", () => _run("分类列表", () => service.categories())),
      _buildBtn("标签列表", () => _run("标签列表", () => service.tags())),
      _buildBtn("帖子列表", () =>
          _run("帖子列表", () =>
              service.forums(
                pageParams: PageParams(limit: 5, page: 1),
                sort: "latest",
              ))),
      _buildBtn("用户帖子", () =>
          _run("用户帖子",
                  () => service.userPosts(PageParams(page: 1, limit: 3), 1))),
      _buildBtn("我的收藏", () =>
          _run(
              "我的收藏", () =>
              service.myFavorites(PageParams(page: 1, limit: 5)))),
      _buildBtn("我点赞的帖子", () =>
          _run(
              "我点赞的帖子", () =>
              service.myLiked(PageParams(page: 1, limit: 5)))),
      _buildBtn(
          "点赞帖子", () => _run("点赞帖子", () => service.vote(1, "up"))),
      _buildBtn("取消帖子点赞", () =>
          _run("取消帖子点赞", () => service.voteCancel(1))),
      _buildBtn("收藏帖子", () => _run("收藏帖子", () => service.favorite(1))),
      _buildBtn(
          "添加评论", () =>
          _run("添加评论", () => service.comment(1, "测试评论"))),

      _buildBtn(
          "评论点赞", () =>
          _run("评论点赞", () => service.commentVote(1, "up"))),
      _buildBtn("取消评论点赞",
              () => _run("取消评论点赞", () => service.commentVoteCancel(1))),
      _buildBtn("记录浏览", () => _run("记录浏览", () => service.view(1))),
      _buildBtn("分享帖子",
              () => _run("分享帖子", () => service.share(1, "wechat"))),
      _buildBtn("帖子详情", () => _run("帖子详情", () => service.detail(1))),
      _buildBtn("评论列表",
              () =>
              _run("评论列表", () =>
                  service.comments(PageParams(page: 1, limit: 99), 1))),
      _buildBtn("子评论列表",
              () =>
              _run("子评论列表", () =>
                  service.commentChildren(PageParams(page: 1, limit: 99), 1))),
      _buildBtn(
          "添加子评论", () =>
          _run("添加子评论", () =>
              service.comment(1, "这是一条子评论", parentId: 1))),
      _buildBtn(
          "我的历史", () =>
          _run("我的历史", () =>
              service.myHistory(PageParams(page: 1, limit: 10)))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("ForumService 接口测试")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                const Text("🧪 点击按钮测试接口：",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...buttons,
                const SizedBox(height: 20),
                const Text("🧩 接口返回结果：",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: _loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          foregroundColor: Colors.white,
        ),
        child: Text(title),
      ),
    );
  }
}