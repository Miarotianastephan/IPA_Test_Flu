import 'package:dio/dio.dart';

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

  Future<ApiResponse<UserInfo>> visitorLogin([String code = ""]) { 
    return post<UserInfo>(
      UserApi.visitorLogin,
      body: {"code": code},
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

  Future<ApiResponse<String>> bindPassword(String username, String password) {
    return post<String>(
      UserApi.bindPassword,
      body: {"username": username, "password": password},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> follow(int id) {
    return post<String>(
      UserApi.follow,
      body: {"id": id},
      fromJson: (json) => json.toString(),
    );
  }

  Future<ApiResponse<String>> unfollow(int id) {
    return post<String>(
      UserApi.unfollow,
      body: {"id": id},
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
    int page = 0,
    int limit = 20,
    String keyword = "",
  ]) {
    return post<PageResponse<UserInfo>>(
      UserApi.searchUsers,
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

  Future<ApiResponse<String>> firstOpen(Map<String, dynamic> deviceData) {
    return post<String>(
      UserApi.firstOpen,
      body: deviceData,
      fromJson: (json) => json.toString(),
    );
  }
}
