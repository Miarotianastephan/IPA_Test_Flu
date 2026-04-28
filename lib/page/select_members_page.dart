import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/page_response.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/empty_widget.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../provider/api_provider.dart';
import '../provider/search_user_list_provider.dart';

class SelectMembersPage extends ConsumerStatefulWidget {
  final List<UserInfo> initialSelected;

  const SelectMembersPage({super.key, this.initialSelected = const []});

  @override
  ConsumerState<SelectMembersPage> createState() => _SelectMembersPageState();
}

class _SelectMembersPageState extends ConsumerState<SelectMembersPage>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedUserIds = {};
  final Map<String, UserInfo> _selectedUsers = {};
  final ScrollController _followsScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  late TabController _tabController;

  List<UserInfo> _followResults = [];
  int _followPage = 1;
  bool _followLoading = false;
  bool _followLoaded = false;
  bool _followFinished = false;

  // État pour l'onglet "Recherche"
  String _searchKeyword = "";
  bool _hasSearched = false;
  bool _searchUserLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    for (var user in widget.initialSelected) {
      _selectedUserIds.add(user.id);
      _selectedUsers[user.id] = user;
    }

    _loadFollows();
    _followsScrollController.addListener(_onFollowsScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _followsScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onFollowsScroll() {
    if (_followsScrollController.position.pixels >=
        _followsScrollController.position.maxScrollExtent - 200) {
      _loadFollows();
    }
  }

  Future<void> _loadFollows({bool refresh = false}) async {
    if (_followLoading) return;
    if (_followFinished && !refresh) return;

    setState(() => _followLoading = true);

    final userService = ref.read(userServiceProvider);

    if (refresh) {
      _followPage = 1;
      _followFinished = false;
      _followResults = [];
    }

    final resp = await userService.myFollowings(_followPage, 20);

    if (!mounted) return;

    if (resp.code == 1 && resp.data != null) {
      PageResponse<UserInfo> pageData = resp.data!;

      setState(() {
        _followLoaded = true;
        if (refresh) {
          _followResults = pageData.list;
        } else {
          _followResults.addAll(pageData.list);
        }

        if (pageData.list.length < 20) {
          _followFinished = true;
        } else {
          _followPage++;
        }
      });
    } else {
      setState(() {
        _followFinished = true;
      });
    }

    setState(() => _followLoading = false);
  }

  void _fetchSearchUsers() {
    if (_searchKeyword.isEmpty) return;

    setState(() {
      _hasSearched = true;
    });

    ref
        .read(searchUserListProvider(_searchKeyword).notifier)
        .fetch(refresh: true);
  }

  void _loadMoreSearchUsers() {
    if (_searchKeyword.isEmpty) return;

    final notifier = ref.read(searchUserListProvider(_searchKeyword).notifier);
    final state = ref.read(searchUserListProvider(_searchKeyword));

    if (state.loading || state.finished) return;
    notifier.fetch(refresh: false);
  }

  void _toggleSelection(UserInfo user) {
    setState(() {
      if (_selectedUserIds.contains(user.id)) {
        _selectedUserIds.remove(user.id);
        _selectedUsers.remove(user.id);
      } else {
        _selectedUserIds.add(user.id);
        _selectedUsers[user.id] = user;
      }
    });
  }

  void _confirmSelection() {
    Navigator.pop(context, _selectedUsers.values.toList());
  }

  Widget _buildUserTile(UserInfo user) {
    final isSelected = _selectedUserIds.contains(user.id);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        child: user.avatar == null
            ? Text(
                user.nickname?.substring(0, 1) ?? "?",
                style: const TextStyle(color: Colors.white, fontSize: 20),
              )
            : ClipOval(
                child: Image.network(
                  user.avatar!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      user.nickname?.substring(0, 1) ?? "?",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    );
                  },
                ),
              ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.nickname ?? "User ${user.id}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          VipBadge(vip: user.vip),
        ],
      ),
      subtitle: user.bio != null
          ? Text(
              user.bio!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Checkbox(
        value: isSelected,
        onChanged: (_) => _toggleSelection(user),
        activeColor: Colors.blue,
        checkColor: Colors.white,
      ),
      onTap: () => _toggleSelection(user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    // Écouter les changements de recherche
    ref.listen(searchUserListProvider(_searchKeyword), (prev, next) {
      if (prev?.loading == true && next.loading == false) {
        setState(() => _searchUserLoaded = true);
      }
    });

    final searchUserState = ref.watch(searchUserListProvider(_searchKeyword));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(translate("selectMembers")),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          tabs: [
            Tab(text: translate("myFollows")),
            Tab(text: translate("search")),
          ],
        ),
        actions: [
          if (_selectedUserIds.isNotEmpty)
            TextButton(
              onPressed: _confirmSelection,
              child: Text(
                "${translate("confirm")} (${_selectedUserIds.length})",
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowsTab(translate),
          _buildSearchTab(translate, searchUserState),
        ],
      ),
    );
  }

  Widget _buildFollowsTab(String Function(String) translate) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black87,
      onRefresh: () => _loadFollows(refresh: true),
      child: !_followLoaded && _followLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _followResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.white38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        translate("noFollowsFound"),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _followsScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _followResults.length + (_followLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _followResults.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    final user = _followResults[index];
                    return _buildUserTile(user);
                  },
                ),
    );
  }

  Widget _buildSearchTab(
    String Function(String) translate,
    dynamic searchUserState,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: translate("pleaseEnterYourUsernameOrId"),
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) {
              final vTrim = v.trim();
              setState(() {
                _searchKeyword = vTrim;
                _searchUserLoaded = false;
                if (_searchKeyword.isEmpty) {
                  _hasSearched = false;
                }
              });

              if (_searchKeyword.isNotEmpty) {
                _fetchSearchUsers();
              }
            },
          ),
        ),
        Expanded(
          child: !_hasSearched
              ? Center(
                  child: EmptyWidget(
                    message: translate("searchUsernameOrIdPlaceholder"),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black87,
                  onRefresh: () async => _fetchSearchUsers(),
                  child:
                      searchUserState.list.isEmpty && !searchUserState.loading
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.white38,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    translate("noResultsFound"),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: searchUserState.list.length +
                                  (searchUserState.loading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == searchUserState.list.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                final user = searchUserState.list[index];
                                return _buildUserTile(user);
                              },
                            ),
                ),
        ),
      ],
    );
  }
}
