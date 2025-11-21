import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/page_response.dart';
import '../../models/userinfo.dart';
import '../../provider/api_provider.dart';
import '../../widgets/general_user_tab.dart';

class MyFansPage extends ConsumerStatefulWidget {
  const MyFansPage({super.key});

  @override
  ConsumerState<MyFansPage> createState() => _MyFansPageState();
}

class _MyFansPageState extends ConsumerState<MyFansPage> {
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

    final resp = await userService.myFans(_page, 20);

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
      appBar: AppBar(title: const Text("我的粉丝")),
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
