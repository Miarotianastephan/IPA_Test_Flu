import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:live_app/api/vip_api.dart';
import 'package:live_app/models/content_bought.dart';
import 'package:live_app/models/emoji.dart';
import 'package:live_app/models/file.dart';
import 'package:live_app/models/first_open.dart';
import 'package:live_app/models/notif_chinese.dart';
import 'package:live_app/models/page_params.dart';
import 'package:live_app/models/time_package.dart';
import 'package:live_app/utils/percent_watch.dart';

import '../../models/api_response.dart';
import '../../models/page_response.dart';
import '../../models/userinfo.dart';
import '../user_api.dart';
import 'base_service.dart';

class UserService extends BaseService {
  UserService(super.client);
  double percentWatch = PercentWatch.percent;
  Future<ApiResponse<UserInfo>> login(String username, String password) {
    return post<UserInfo>(
      UserApi.login,
      body: {"username": username, "password": password},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> visitorLogin(
    int idFirstOpen, {
    String? userid,
    String? code,
    Map<String, dynamic>? trackingQueryParams,
  }) {
    Map<String, dynamic> body = {"id_first_open": idFirstOpen};

    if (userid != null) {
      body["user_id"] = userid;
    }
    if (code != null) {
      body["code"] = code;
    }
    if (trackingQueryParams != null && trackingQueryParams.isNotEmpty) {
      body["tracking_query_params"] = trackingQueryParams;
    }

    return post<UserInfo>(
      UserApi.visitorLogin,
      body: body,
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> loginByCredential(String credential) {
    return post<UserInfo>(
      UserApi.loginByCredential,
      body: {"credential": credential},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> updateInfo(FormData formData) {
    return post<UserInfo>(
      UserApi.updateInfo,
      body: formData,
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> getInfo() {
    return post<UserInfo>(
      UserApi.getInfo,
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<String>> updatePassword(
    String newPassword,
    String oldPassword,
  ) {
    return post<String>(
      UserApi.updatePassword,
      body: {"new_password": newPassword, "old_password": oldPassword},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> bindPassword(
    String username,
    String nickname,
    String password,
  ) {
    return post<String>(
      UserApi.bindPassword,
      body: {"username": username, "nickname": nickname, "password": password},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> follow(String userId) {
    return post<String>(
      UserApi.follow,
      body: {"user_id": userId},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> unfollow(String userId) {
    return post<String>(
      UserApi.unfollow,
      body: {"user_id": userId},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<PageResponse<UserInfo>>> myFans([
    int page = 0,
    int limit = 20,
    String keyword = "",
  ]) {
    return post<PageResponse<UserInfo>>(
      UserApi.myFans,
      body: {"page": page, "limit": limit, "keyword": keyword},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => UserInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<UserInfo>>> myFollowings([
    int page = 0,
    int limit = 20,
    String keyword = "",
  ]) {
    return post<PageResponse<UserInfo>>(
      UserApi.myFollowings,
      body: {"page": page, "limit": limit, "keyword": keyword},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => UserInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<UserInfo>> bindInviteCode([String code = ""]) {
    return post<UserInfo>(
      UserApi.bindInviteCode,
      body: {"code": code},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> refreshToken() {
    return post<UserInfo>(
      UserApi.refreshToken,
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<PageResponse<UserInfo>>> searchUsers([
    int page = 1,
    int limit = 20,
    String keyword = "",
  ]) {
    return post<PageResponse<UserInfo>>(
      UserApi.searchUsers,
      body: {"page": page, "limit": limit, "name": keyword},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => UserInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<UserInfo>>> mutualFollowings([
    int page = 0,
    int limit = 20,
    String keyword = "",
  ]) {
    return post<PageResponse<UserInfo>>(
      UserApi.mutualFollowings,
      body: {"page": page, "limit": limit, "keyword": keyword},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => UserInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<UserInfo>> getInfoById(String userId) {
    return post<UserInfo>(
      UserApi.getInfoById,
      body: {"user_id": userId},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<FirstOpen>> firstOpen(
    Map<String, dynamic> deviceData,
  ) async {
    final responseMap = await post<Map<String, dynamic>>(
      UserApi.firstOpen,
      body: deviceData,
      fromJson: (json) => json as Map<String, dynamic>,
    );

    return ApiResponse<FirstOpen>.fromJson(
      responseMap.toJson((value) => value),
      (json) => FirstOpen.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PageResponse<Emoji>>> getEmojis(PageParams params) {
    return post<PageResponse<Emoji>>(
      UserApi.emojis,
      body: {...params.toJson()},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => Emoji.fromJson(item)),
    );
  }

  Future<ApiResponse<File>> uploadFile(
    String filePath, {
    Uint8List? bytes,
    String? fileName,
    String type = 'image',
  }) async {
    FormData formData;

    if (kIsWeb && bytes != null) {
      formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
        "type": type,
      });
    } else {
      formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath),
        "type": type,
      });
    }

    return post<File>(
      UserApi.upload,
      body: formData,
      fromJson: (json) => File.fromJson(json),
    );
  }

  Future<ApiResponse<String>> buyContent(String type, String typeId) async {
    return post<String>(
      UserApi.buyContent,
      body: {"id_type": typeId, "type": type},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<PageResponse<ContentBought>>> findContentBought({
    required String type,
    required int page,
    required int limit,
  }) {
    return post<PageResponse<ContentBought>>(
      UserApi.getContentBought,
      body: {"type": type, "page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ContentBought.fromJson(item)),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> recordPreview(String videoId) {
    return post<Map<String, dynamic>>(
      UserApi.recordPreview,
      body: {'video_id': videoId},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// Get remaining preview quota for today
  /// Returns {remaining: int, total: int, resetAt: DateTime}
  Future<ApiResponse<Map<String, dynamic>>> getPreviewQuota() {
    return post<Map<String, dynamic>>(
      UserApi.getPreviewQuota,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<UserInfo>> buyWithWallet(int vipId) {
    return post<UserInfo>(
      VipApi.buy,
      body: {"vip_id": vipId},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<PageResponse<TimePackage>>> getTimePackages({
    required int page,
    required int limit,
  }) {
    return post<PageResponse<TimePackage>>(
      UserApi.getTimePackages,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => TimePackage.fromJson(item)),
    );
  }

  Future<ApiResponse<UserInfo>> buyTimePackageWithWallet(int timePackageId) {
    return post<UserInfo>(
      UserApi.buyTimePackageWithWallet,
      body: {"timePackageId": timePackageId},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<UserInfo>> updateRemainingTime({required int duration}) {
    return post<UserInfo>(
      UserApi.updateRemainingTime,
      body: {"duration": duration},
      fromJson: (json) => UserInfo.fromJson(json),
    );
  }

  Future<ApiResponse<void>> userInterest({
    required String userId,
    required String videoId,
    required int watchDuration,
    required int videoDuration,
  }) {
    return post<void>(
      UserApi.userInterest,
      body: {
        "userId": userId,
        "videoId": videoId,
        "watchDuration": watchDuration,
        "videoDuration": videoDuration,
      },
      fromJson: (_) {},
    );
  }

  Future<ApiResponse<void>> userPostInterest({
    required String postId,
    required String interactionType,
    int? watchDuration,
    int? videoDuration,
  }) {
    final body = <String, dynamic>{
      "postId": postId,
      "interactionType": interactionType,
    };
    if (watchDuration != null) {
      body["watchDuration"] = watchDuration;
    }
    if (videoDuration != null) {
      body["videoDuration"] = videoDuration;
    }

    return post<void>(UserApi.userPostInterest, body: body, fromJson: (_) {});
  }

  Future<ApiResponse<PageResponse<UserInfo>>> getSponsoredUser({
    required int page,
    required int limit,
  }) {
    return post<PageResponse<UserInfo>>(
      UserApi.getSponsoredUser,
      body: {"page": page, "limit": limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => UserInfo.fromJson(item)),
    );
  }

  Future<ApiResponse<({int amount, int forceReload})>> checkUserGiftReceive() {
    return post<({int amount, int forceReload})>(
      UserApi.checkUserGiftReceive,
      fromJson: (json) => (
        amount: json['amount'] as int? ?? 0,
        forceReload: json['forceReload'] as int? ?? 0,
      ),
    );
  }

  Future<ApiResponse<NotifChinese>> getNotifChinese() {
    return post<NotifChinese>(
      UserApi.getNotifCn,
      fromJson: (json) => NotifChinese.fromJson(json),
    );
  }
}
