import 'package:dio/dio.dart';
import 'package:live_app/models/emoji.dart';
import 'package:live_app/models/file.dart';
import 'package:live_app/models/first_open.dart';
import 'package:live_app/models/page_params.dart';

import '../../models/api_response.dart';
import '../../models/page_response.dart';
import '../../models/userinfo.dart';
import '../user_api.dart';
import 'base_service.dart';

class UserService extends BaseService {
  UserService(super.client);

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
  }) {
    Map<String, dynamic> body = {"id_first_open": idFirstOpen};

    if (userid != null) {
      body["user_id"] = userid;
    }
    if (code != null) {
      body["code"] = code;
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

  Future<ApiResponse<String>> follow(int userId) {
    return post<String>(
      UserApi.follow,
      body: {"user_id": userId.toString()},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> unfollow(int userId) {
    return post<String>(
      UserApi.unfollow,
      body: {"user_id": userId.toString()},
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

  Future<ApiResponse<UserInfo>> getInfoById(int userId) {
    return post<UserInfo>(
      UserApi.getInfoById,
      body: {"user_id": userId.toString()},
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

  Future<ApiResponse<File>> uploadFile(String filePath) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath),
    });

    return post<File>(
      UserApi.upload,
      body: formData,
      fromJson: (json) => File.fromJson(json),
    );
  }
}
