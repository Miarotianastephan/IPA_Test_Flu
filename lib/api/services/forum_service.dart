import '../../models/api_response.dart';
import '../../models/forum_category.dart';
import '../../models/forum_comment.dart';
import '../../models/forum_post.dart';
import '../../models/forum_tag.dart';
import '../../models/page_params.dart';
import '../../models/page_response.dart';
import '../forum_api.dart';
import 'base_service.dart';

class ForumService extends BaseService {
  ForumService(super.client);

  /// 获取论坛分类列表
  Future<ApiResponse<List<ForumCategory>>> categories() {
    return post<List<ForumCategory>>(
      ForumApi.categories,
      body: {}, // 空对象即可
      fromJson: (json) {
        final list = (json as List)
            .map((item) => ForumCategory.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      },
    );
  }

  /// 获取标签列表
  Future<ApiResponse<List<ForumTag>>> tags() {
    return post<List<ForumTag>>(
      ForumApi.tags,
      body: {}, // 空对象即可
      fromJson: (json) {
        final list = (json as List)
            .map((item) => ForumTag.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      },
    );
  }

  /// 获取帖子列表（分页、分类、标签、关键词）
  Future<ApiResponse<PageResponse<ForumPost>>> forums({
    required PageParams pageParams,
    String? keyword,
    int? tagId,
    int? categoryId,
    String? sort,
  }) {
    final body = <String, dynamic>{
      ...pageParams.toJson(),
      if (keyword != null && keyword.isNotEmpty) "keyword": keyword,
      if (tagId != null) "tag_id": tagId,
      if (categoryId != null) "categoryId": categoryId,
      if (sort != null && sort.isNotEmpty) "sort": sort,
    };

    return post<PageResponse<ForumPost>>(
      ForumApi.forums,
      body: body,
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumPost.fromJson(item)),
    );
  }

  /// 获取指定用户的帖子
  Future<ApiResponse<PageResponse<ForumPost>>> userPosts(
    PageParams params,
    int userId,
  ) {
    return post<PageResponse<ForumPost>>(
      ForumApi.userPosts,
      body: {...params.toJson(), "id": userId.toString()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumPost.fromJson(item)),
    );
  }

  /// 我的收藏帖子
  Future<ApiResponse<PageResponse<ForumPost>>> myFavorites(PageParams params) {
    return post<PageResponse<ForumPost>>(
      ForumApi.myFavorites,
      body: params.toJson(),
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumPost.fromJson(item)),
    );
  }

  /// 我点赞的帖子
  Future<ApiResponse<PageResponse<ForumPost>>> myLiked(PageParams params) {
    return post<PageResponse<ForumPost>>(
      ForumApi.myLiked,
      body: params.toJson(),
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumPost.fromJson(item)),
    );
  }

  /// 我的历史
  Future<ApiResponse<PageResponse<ForumPost>>> myHistory(PageParams params) {
    return post<PageResponse<ForumPost>>(
      ForumApi.history,
      body: params.toJson(),
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumPost.fromJson(item)),
    );
  }

  /// 帖子点赞/踩
  /// voteType: "up" 或 "down"
  Future<ApiResponse<String>> vote(int postId, String voteType) {
    return post<String>(
      ForumApi.vote,
      body: {"id": postId, "vote_type": voteType},
      fromJson: (json) => json.toString(),
    );
  }

  /// 取消帖子点赞/踩
  Future<ApiResponse<String>> voteCancel(int postId) {
    return post<String>(
      ForumApi.voteCancel,
      body: {"id": postId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 收藏或取消收藏
  Future<ApiResponse<String>> favorite(int postId) {
    return post<String>(
      ForumApi.favorite,
      body: {"id": postId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 添加评论（支持父评论）
  Future<ApiResponse<ForumComment>> comment(
    int postId,
    String content, {
    int? parentId,
  }) {
    final body = {
      "post_id": postId,
      "content": content,
      if (parentId != null) "parent_id": parentId,
    };
    return post<ForumComment>(
      ForumApi.comment,
      body: body,
      fromJson: (json) => ForumComment.fromJson(json),
    );
  }

  /// 评论点赞/踩
  Future<ApiResponse<String>> commentVote(int commentId, String voteType) {
    return post<String>(
      ForumApi.commentVote,
      body: {"id": commentId, "vote_type": voteType},
      fromJson: (json) => json.toString(),
    );
  }

  /// 取消评论点赞/踩
  Future<ApiResponse<String>> commentVoteCancel(int commentId) {
    return post<String>(
      ForumApi.commentVoteCancel,
      body: {"id": commentId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 记录浏览
  Future<ApiResponse<String>> view(int postId) {
    return post<String>(
      ForumApi.view,
      body: {"id": postId},
      fromJson: (json) => json.toString(),
    );
  }

  /// 记录分享（带平台名）
  Future<ApiResponse<String>> share(int postId, String platform) {
    return post<String>(
      ForumApi.share,
      body: {"id": postId, "platform": platform},
      fromJson: (json) => json.toString(),
    );
  }

  /// 帖子详情
  Future<ApiResponse<ForumPost>> detail(int postId) {
    return post(
      ForumApi.detail,
      body: {"id": postId},
      fromJson: (json) => ForumPost.fromJson(json),
    );
  }

  /// 帖子一级评论列表
  Future<ApiResponse<PageResponse<ForumComment>>> comments(
    PageParams params,
    int postId,
  ) {
    return post<PageResponse<ForumComment>>(
      ForumApi.comments,
      body: {...params.toJson(), "id": postId},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumComment.fromJson(item)),
    );
  }

  /// 评论子评论列表
  Future<ApiResponse<PageResponse<ForumComment>>> commentChildren(
    PageParams params,
    int commentId,
  ) {
    return post<PageResponse<ForumComment>>(
      ForumApi.commentChildren,
      body: {...params.toJson(), "id": commentId},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ForumComment.fromJson(item)),
    );
  }
}
