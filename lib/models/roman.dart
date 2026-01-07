import 'package:live_app/models/chapter_roman.dart';
import 'package:live_app/models/creator_roman.dart';
import 'package:live_app/models/roman_category.dart';
import 'package:live_app/models/roman_plateform.dart';
import 'package:live_app/models/roman_sub_category.dart';
import 'package:live_app/models/titles_roman.dart';
import 'package:live_app/models/user_roman.dart';

class Roman {
  final int id;
  final String ref;
  final String? comment;
  final int userId;
  final int creatorId;
  final int categoryId;
  final int subCategoryId;
  final int totalWords;
  final int chaptersCount;
  final bool needVip;
  final bool isDeleted;
  final int plateformId;
  final String? cover;
  final String? s3CoverPath;
  final int coverUploadStatus;
  final String? localCoverPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RomanTitle> titles;
  final RomanCategory category;
  final RomanSubCategory subCategory;
  final RomanCreator creatorObj;
  final RomanPlateform plateform;
  final RomanUser user;
  final List<RomanChapter> chapters;
  final String? s3CoverUrl;
  Roman({
    required this.id,
    required this.ref,
    this.comment,
    required this.userId,
    required this.creatorId,
    required this.categoryId,
    required this.subCategoryId,
    required this.totalWords,
    required this.chaptersCount,
    required this.needVip,
    required this.isDeleted,
    required this.plateformId,
    this.cover,
    this.s3CoverPath,
    required this.coverUploadStatus,
    this.localCoverPath,
    required this.createdAt,
    required this.updatedAt,
    required this.titles,
    required this.category,
    required this.subCategory,
    required this.creatorObj,
    required this.plateform,
    required this.user,
    required this.chapters,
    this.s3CoverUrl,
  });
  factory Roman.fromJson(Map<String, dynamic> json) {
    return Roman(
      id: json['id'],
      ref: json['ref'],
      comment: json['comment'],
      userId: json['user_id'],
      creatorId: json['creator_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      totalWords: json['total_words'],
      chaptersCount: json['chapters_count'],
      needVip: json['need_vip'],
      isDeleted: json['isDeleted'],
      plateformId: json['plateform_id'],
      cover: json['cover'],
      s3CoverPath: json['s3_cover_path'],
      coverUploadStatus: json['cover_upload_status'],
      localCoverPath: json['local_cover_path'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      titles: (json['titles'] as List)
          .map((t) => RomanTitle.fromJson(t))
          .toList(),
      category: RomanCategory.fromJson(json['category']),
      subCategory: RomanSubCategory.fromJson(json['subCategory']),
      creatorObj: RomanCreator.fromJson(json['creatorObj']),
      plateform: RomanPlateform.fromJson(json['plateform']),
      user: RomanUser.fromJson(json['user']),
      chapters: (json['chapters'] as List)
          .map((c) => RomanChapter.fromJson(c))
          .toList(),
      s3CoverUrl: json['s3_cover_url'],
    );
  }
}
