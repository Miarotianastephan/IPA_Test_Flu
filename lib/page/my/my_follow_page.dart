import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/widgets/general_user_tab.dart';

import '../../provider/api_provider.dart';

class MyFollowPage extends ConsumerStatefulWidget {
  const MyFollowPage({super.key});

  @override
  ConsumerState<MyFollowPage> createState() => _MyFollowPageState();
}

class _MyFollowPageState extends ConsumerState<MyFollowPage> {
  List<UserInfo> _results = [];
  int _page = 1;
  bool _loading = false;
  bool _isLoaded = false;
  bool _finished = false;

  Future<void> _load({bool refresh = false}) async {
    if (_loading) return;

    setState(() => _loading = true);

    final userService = ref.read(userServiceProvider);

    if (refresh) {
      _page = 1;
      _finished = false;
      _results = [];
    }

    final resp = await userService.myFollowings(_page, 20);

    if (!mounted) return;

    if (resp.code == 1 && resp.data != null) {
      PageResponse<UserInfo> pageData = resp.data!;

      setState(() {
        _isLoaded = true;
        if (refresh) {
          _results = pageData.list;
        } else {
          _results.addAll(pageData.list);
        }

        if (pageData.list.length < 20) {
          _finished = true;
        } else {
          _page++;
        }
      });
    }

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("我的关注"), backgroundColor: Colors.black),
      body: GeneralUserTab(
        loading: _loading,
        results: _results,
        isLoaded: _isLoaded,
        onRefresh: () => _load(refresh: true),
        onLoadMore: () => _load(),
        finished: _finished,
      ),
    );
  }
}
