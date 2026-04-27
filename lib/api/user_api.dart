class UserApi {
  static const String base = "/api/user";

  //token刷新
  static const String refreshToken = '$base/refreshToken';

  //访客登录
  static const String visitorLogin = '$base/visitorLogin';

  //更新用户信息
  static const String updateInfo = '$base/users/updateInfo';

  //获取用户信息
  static const String getInfo = '$base/getInfo';
  //通过ID获取用户信息
  static const String getInfoById = '$base/getInfoById';

  //更新密码
  static const String updatePassword = '$base/users/updatePassword';

  //绑定密码
  static const String bindPassword = '$base/users/bindPassword';

  //关注用户
  static const String follow = '$base/follow';

  //取消关注用户
  static const String unfollow = '$base/unfollow';

  //我的粉丝列表
  static const String myFans = '$base/myFans';

  //我的关注列表
  static const String myFollowings = '$base/myFollowings';

  //绑定邀请码
  static const String bindInviteCode = '$base/bindInviteCode';

  //搜索用户
  static const String searchUsers = '$base/users/searchUsers';

  //账号密码登录
  static const String login = '$base/login';

  //凭证登录
  static const String loginByCredential = '$base/loginByCredential';

  //首次打开应用
  static const String firstOpen = '$base/v1/first_open';
  //互相关注的用户列表
  static const String mutualFollowings = '$base/mutualFollowings';

  static const String emojis = "$base/emojis";

  // 上传文件
  static const String upload = "$base/files/upload";

  static const String buyContent = '$base/buyContent';
  static const String getContentBought = "$base/findContentBought";

  static const String recordPreview = "$base/preview/record";
  static const String getPreviewQuota = "$base/preview/quota";

  static const String getCurrencyEndpoint = '$base/get-currency';

  static const String trackInstallation = '$base/installations/track';

  static const String getTimePackages = "$base/time-packages";
  static const String buyTimePackageWithWallet =
      "$base/time-packages/buy-with-wallet";
  static const String updateRemainingTime =
      "$base/time-packages/update-remaining-time";

  static const String userInterest = '$base/user-interest/update-from-watch';
  static const String userPostInterest =
      '$base/f-user-interest/update-from-interaction';

  static const String getSponsoredUser = '$base/getSponsoredUser';

  static const String checkUserGiftReceive = '$base/checkUserGiftReceive';

  static const String getNotifCn = '$base/app/getNotifCN';
}
