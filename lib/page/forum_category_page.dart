import 'package:flutter/material.dart';
import '../../models/forum_category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/api_provider.dart';
import 'forum_tag_category_page.dart';

class ForumCategoryPage extends StatefulWidget {
  const ForumCategoryPage({super.key});

  @override
  State<ForumCategoryPage> createState() => _ForumCategoryPageState();
}

class _ForumCategoryPageState extends State<ForumCategoryPage> {
  List<ForumCategory> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final forumService = container.read(forumServiceProvider);
    final cats = await forumService.categories();
    if (mounted) {
      setState(() {
        _categories = cats.data ?? [];
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildAllSections(List<ForumCategory> roots) {
    final sections = <Map<String, dynamic>>[];

    List<ForumCategory> flatten(ForumCategory node) {
      final result = <ForumCategory>[];
      final queue = <ForumCategory>[];
      if (node.children != null && node.children!.isNotEmpty) {
        queue.addAll(node.children!);
      }
      final seen = <int?>{};
      while (queue.isNotEmpty) {
        final cur = queue.removeAt(0);
        if (seen.contains(cur.id)) continue;
        seen.add(cur.id);
        result.add(cur);
        if (cur.children != null && cur.children!.isNotEmpty) {
          queue.addAll(cur.children!);
        }
      }
      return result;
    }

    void traverse(List<ForumCategory> nodes, {bool isRoot = false}) {
      for (final node in nodes) {
        final hasChildren = node.children != null && node.children!.isNotEmpty;

        if (isRoot) {
          if (hasChildren) {
            sections.add({'parent': node, 'children': flatten(node)});
            traverse(node.children!, isRoot: false);
          } else {
            sections.add({'parent': node, 'children': <ForumCategory>[]});
          }
        } else {
          if (hasChildren) {
            sections.add({'parent': node, 'children': flatten(node)});
            traverse(node.children!, isRoot: false);
          }
        }
      }
    }

    traverse(roots, isRoot: true);
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final sections = _buildAllSections(_categories);
    return Scaffold(
      appBar: AppBar(title: const Text('全部分类'), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final parentCategory = section['parent'] as ForumCategory;
                final children = section['children'] as List<ForumCategory>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            parentCategory.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForumTagCategoryPage(
                                    title: parentCategory.name,
                                    type: "category",
                                    id: parentCategory.id,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  '全部',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (children.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: children.map((child) {
                            return ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForumTagCategoryPage(
                                      title: child.name,
                                      type: "category",
                                      id: child.id,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              child: Text(child.name),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
