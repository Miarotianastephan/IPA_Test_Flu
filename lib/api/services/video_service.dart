import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:live_app/config/storage_config.dart';
import 'package:live_app/models/search_video_request.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/models/video_comment.dart';
import 'package:live_app/models/video_tag.dart';

import '../../models/api_response.dart';
import '../../models/video_category.dart';
import '../../models/page_params.dart';
import '../../models/page_response.dart';
import '../../models/video_info.dart';
import '../video_api.dart';
import 'base_service.dart';

class VideoService extends BaseService {
  VideoService(super.client);

  Future<ApiResponse<PageResponse<VideoInfo>>> homeList(
    PageParams params,
    int type,
    int featuredType,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.homeList,
      body: {...params.toJson(), "type": type, "featured_type": featuredType},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<String>> favoriteVideo(int videoId) async {
    return post<String>(
      VideoApi.favoriteVideo,
      body: {
        "video_id": videoId.toString(),
      },
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> unFavoriteVideo(int videoId) async {
    return post<String>(
      VideoApi.unFavoriteVideo,
      body: {
        "video_id": videoId.toString(),
      },
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> shareVideo(int id) {
    return post<String>(
      VideoApi.shareVideo,
      body: {"id": id},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> unlikeVideo(int videoId) async {
    return post<String>(
      VideoApi.unlikeVideo,
      body: {
        "video_id": videoId.toString(),
      },
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> likeVideo(int videoId) async {
    return post<String>(
      VideoApi.likeVideo,
      body: {
        "video_id": videoId.toString(),
      },
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<VideoComment>> commentVideo(
    int id,
    String content, {
    int? parentId,
  }) async {
    final jsonString = await StorageService.instance.getValue("user_info");
    if (jsonString == null || jsonString.isEmpty) {
      throw Exception("Utilisateur non connecté");
    }
    final currentUser = UserInfo.fromJson(jsonDecode(jsonString));
    final body = {
      "id": id.toString(),
      "content": content,
      "user_id": currentUser.id.toString(),
      if (parentId != null) "parent_id": parentId.toString(),
    };

    return post<VideoComment>(
      VideoApi.commentVideo,
      body: body,
      fromJson: (json) => VideoComment.fromJson(json),
    );
  }

  Future<ApiResponse<PageResponse<VideoComment>>> videoRootCommentList(
    PageParams params,
    int id,
  ) {
    return post<PageResponse<VideoComment>>(
      VideoApi.videoRootCommentList,
      body: {...params.toJson(), "id": id.toString()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoComment.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoComment>>> videoChildCommentList(
    PageParams params,
    int idComment,
  ) {
    return post<PageResponse<VideoComment>>(
      VideoApi.videoChildCommentList,
      body: {...params.toJson(), "idComment": idComment.toString()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoComment.fromJson(item)),
    );
  }

  Future<ApiResponse<String>> likeComment(int commentId) {
    return post<String>(
      VideoApi.likeComment,
      body: {"comment_id": commentId.toString()},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> cancelCommentLike(int commentId) async {
    return post<String>(
      VideoApi.cancelCommentLike,
      body: {"comment_id": commentId.toString() },
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> userVideos(
    PageParams params,
    int userId,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.userVideos,
      body: {...params.toJson(), "user_id": userId.toString()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> userFavorites(
    PageParams params,
    int userId,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.userFavorites,
      body: {...params.toJson(), "id": userId},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoCategory>>> categoryList(
    PageParams params, {
    bool onlyHome = false,
  }) {
    return post<PageResponse<VideoCategory>>(
      VideoApi.categoryList,
      body: {...params.toJson(), "only_home": onlyHome},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoCategory.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoTag>>> tagList(
    PageParams params, {
    bool onlyHome = false,
  }) {
    return post<PageResponse<VideoTag>>(
      VideoApi.tagList,
      body: {...params.toJson()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoTag.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> searchVideos(
    SearchVideoRequest req,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.searchVideos,
      body: req.toJson(),
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<VideoInfo>> detail(int videoId) {
    return post<VideoInfo>(
      VideoApi.detail,
      body: {"id": videoId},
      fromJson: (json) => VideoInfo.fromJson(json),
    );
  }

  Future<ApiResponse<String>> seen(int videoId) {
    return post<String>(
      VideoApi.seen,
      body: {"id": videoId},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> relevanceRecommend(
    PageParams params,
    int videoId,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.relevanceRecommend,
      body: {...params.toJson(), "id": videoId.toString()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> favoriteList(
    PageParams params,
    int type,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.favoriteList,
      body: {...params.toJson(), "type": type},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> historyList(
    PageParams params,
    int type,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.historyList,
      body: {...params.toJson(), "type": type},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<VideoInfo>>> likeList(
    PageParams params,
    int type,
  ) {
    return post<PageResponse<VideoInfo>>(
      VideoApi.likeList,
      body: {...params.toJson(), "type": type},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => VideoInfo.fromJson(item)),
    );
  }
}
