class VideoApi {
  static const String base = "/api/user/video";
  static const String homeList = '$base/homeList';
  static const String favoriteVideo = '$base/favoriteVideo';
  static const String unFavoriteVideo = '$base/unFavoriteVideo';
  static const String shareVideo = '$base/shareVideo';
  static const String unlikeVideo = '$base/unlikeVideo';
  static const String likeVideo = '$base/likeVideo';
  static const String commentVideo = '$base/commentVideo';
  static const String videoRootCommentList = '$base/videoRootCommentList';
  static const String videoChildCommentList = '$base/videoChildCommentList';
  static const String likeComment = '$base/likeComment';
  static const String cancelCommentLike = '$base/cancelCommentLike';
  static const String userVideos = '$base/userVideos';
  static const String userFavorites = '$base/userFavorites';
  static const String categoryList = '$base/categoryList';
  static const String tagList = '$base/tagList';
  static const String searchVideos = '$base/searchVideos';

  static const String detail = '$base/detail';
  static const String seen = '$base/seen';
  static const String relevanceRecommend =  '$base/relevanceRecommend';



  static const String favoriteList =  '$base/favoriteList';
  static const String historyList =  '$base/historyList';
  static const String likeList =  '$base/likeList';
}