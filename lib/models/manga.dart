import 'package:live_app/models/chapter_manga.dart';
import 'package:live_app/models/creator_manga.dart';
import 'package:live_app/models/manga_category.dart';
import 'package:live_app/models/manga_sub_category.dart';
import 'package:live_app/models/titles_manga.dart';
import 'package:live_app/models/user_manga.dart';

class Manga {
  final int id;
  final String ref;
  final String title;
  final String description;
  final String? checking;
  final String? processing;
  final String? comment;
  final int userId;
  final int totalChapters;
  final int categoryId;
  final int subCategoryId;
  final String cover;
  final String s3CoverPath;
  final int coverUploadStatus;
  final String localCoverPath;
  final String hash;
  final bool sendToServer;
  final bool needVip;
  final String creator;
  final int creatorId;
  final bool isDeleted;
  final int plateformId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final MangaCategory mangasCategory;
  final MangaSubCategory mangasSubCategory;
  final Creator creatorObj;
  final User user;
  final List<TitlesManga> titles;
  final List<ChapterManga> chapters;
  final String s3CoverUrl;
  Manga({
    required this.id,
    required this.ref,
    required this.title,
    required this.description,
    this.checking,
    this.processing,
    this.comment,
    required this.userId,
    required this.totalChapters,
    required this.categoryId,
    required this.subCategoryId,
    required this.cover,
    required this.s3CoverPath,
    required this.coverUploadStatus,
    required this.localCoverPath,
    required this.hash,
    required this.sendToServer,
    required this.needVip,
    required this.creator,
    required this.creatorId,
    required this.isDeleted,
    required this.plateformId,
    required this.createdAt,
    required this.updatedAt,
    required this.mangasCategory,
    required this.mangasSubCategory,
    required this.creatorObj,
    required this.user,
    required this.titles,
    required this.chapters,
    required this.s3CoverUrl,
  });
  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'],
      ref: json['ref'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      checking: json['checking'],
      processing: json['processing'],
      comment: json['comment'],
      userId: json['user_id'],
      totalChapters: json['total_chapters'],
      categoryId: json['mangas_category_id'],
      subCategoryId: json['mangas_sub_category_id'],
      cover: json['cover'] ?? '',
      s3CoverPath: json['s3_cover_path'] ?? '',
      coverUploadStatus: json['cover_upload_status'] ?? 0,
      localCoverPath: json['local_cover_path'] ?? '',
      hash: json['hash'] ?? '',
      sendToServer: json['sendToServer'] ?? false,
      needVip: json['need_vip'] ?? false,
      creator: json['creator'] ?? '',
      creatorId: json['creator_id'],
      isDeleted: json['isDeleted'] ?? false,
      plateformId: json['plateform_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      mangasCategory: MangaCategory.fromJson(json['mangasCategory']),
      mangasSubCategory: MangaSubCategory.fromJson(json['mangasSubCategory']),
      creatorObj: Creator.fromJson(json['creatorObj']),
      user: User.fromJson(json['user']),
      titles: (json['titles'] as List<dynamic>)
          .map((e) => TitlesManga.fromJson(e))
          .toList(),
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => ChapterManga.fromJson(e))
          .toList(),
      s3CoverUrl: json['s3_cover_url'] ?? '',
    );
  }
}
