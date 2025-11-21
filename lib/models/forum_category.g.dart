// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forum_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForumCategory _$ForumCategoryFromJson(Map<String, dynamic> json) =>
    ForumCategory(
      id: parseInt(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      parentId: parseInt(json['parent_id']),
      sort: (json['sort'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ForumCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ForumCategoryToJson(ForumCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parent_id': instance.parentId,
      'sort': instance.sort,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
      'children': instance.children?.map((e) => e.toJson()).toList(),
    };
