import 'package:live_app/models/userinfo.dart';

bool isVisitorUser(UserInfo? userInfo) {
  return userInfo?.isVisitor ?? true;
}

bool isLoggedIn(UserInfo? userInfo) {
  return userInfo != null && !userInfo.isVisitor;
}
