import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/utils/toast_util.dart';

void requireLogin({
  required AppLocalizations localizations,
  required Function action,
  required UserInfo? userInfo,
}) {
  if (userInfo == null) {
    ToastUtil.warning(localizations.mustConnect);
  } else {
    action();
  }
}

bool isVisitorUser(UserInfo? userInfo) {
  return userInfo?.isVisitor ?? true;
}

bool isLoggedIn(UserInfo? userInfo) {
  return userInfo != null && !userInfo.isVisitor;
}
