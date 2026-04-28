import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('zh')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @post.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get post;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get info;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @noSignature.
  ///
  /// In en, this message translates to:
  /// **'No personal signature yet'**
  String get noSignature;

  /// No description provided for @copyId.
  ///
  /// In en, this message translates to:
  /// **'Copy ID'**
  String get copyId;

  /// No description provided for @idCopied.
  ///
  /// In en, this message translates to:
  /// **'ID copied'**
  String get idCopied;

  /// No description provided for @userInfo.
  ///
  /// In en, this message translates to:
  /// **'User Info'**
  String get userInfo;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'My Favorites'**
  String get favorites;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'Watch History'**
  String get history;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'My Likes'**
  String get likes;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @bindPassword.
  ///
  /// In en, this message translates to:
  /// **'Bind Password'**
  String get bindPassword;

  /// No description provided for @filterWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get filterWatching;

  /// No description provided for @filterLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get filterLatest;

  /// No description provided for @filterHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get filterHot;

  /// No description provided for @filterRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get filterRandom;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get follow;

  /// No description provided for @recommend.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommend;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verify;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @noSearchHistory.
  ///
  /// In en, this message translates to:
  /// **'No search history'**
  String get noSearchHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clickedOn.
  ///
  /// In en, this message translates to:
  /// **'Clicked on'**
  String get clickedOn;

  /// No description provided for @mysteriousUser.
  ///
  /// In en, this message translates to:
  /// **'This user is mysterious~'**
  String get mysteriousUser;

  /// No description provided for @followCount.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followCount;

  /// No description provided for @fansCount.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get fansCount;

  /// No description provided for @likeCount.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get likeCount;

  /// No description provided for @followed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get followed;

  /// No description provided for @privateMessage.
  ///
  /// In en, this message translates to:
  /// **'Private Message'**
  String get privateMessage;

  /// No description provided for @works.
  ///
  /// In en, this message translates to:
  /// **'Works'**
  String get works;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'Live Content'**
  String get live;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @bind.
  ///
  /// In en, this message translates to:
  /// **'Bind'**
  String get bind;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get enterPassword;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get enterUsername;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @bindSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bind successful'**
  String get bindSuccess;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter old password'**
  String get enterOldPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPassword;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm new password'**
  String get enterConfirmPassword;

  /// No description provided for @passwordUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdateSuccess;

  /// No description provided for @loginWithCredential.
  ///
  /// In en, this message translates to:
  /// **'Login with Credential Key'**
  String get loginWithCredential;

  /// No description provided for @credentialKey.
  ///
  /// In en, this message translates to:
  /// **'Credential Key'**
  String get credentialKey;

  /// No description provided for @enterCredentialKey.
  ///
  /// In en, this message translates to:
  /// **'Please enter credential key'**
  String get enterCredentialKey;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @loginWithQrcode.
  ///
  /// In en, this message translates to:
  /// **'Login with QR Code'**
  String get loginWithQrcode;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed, please try again'**
  String get scanFailed;

  /// No description provided for @qrcodeNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'No QR code detected'**
  String get qrcodeNotRecognized;

  /// No description provided for @qrcodeParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse QR code'**
  String get qrcodeParseFailed;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on flashlight'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off flashlight'**
  String get flashOff;

  /// No description provided for @uploadQrcode.
  ///
  /// In en, this message translates to:
  /// **'Upload QR Code'**
  String get uploadQrcode;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome to login'**
  String get welcomeLogin;

  /// No description provided for @enterUsernameAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter username and password'**
  String get enterUsernameAndPassword;

  /// No description provided for @otherLoginMethods.
  ///
  /// In en, this message translates to:
  /// **'Other login methods'**
  String get otherLoginMethods;

  /// No description provided for @agreeTo.
  ///
  /// In en, this message translates to:
  /// **'By logging in you agree to '**
  String get agreeTo;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @favoritesPageContent.
  ///
  /// In en, this message translates to:
  /// **'This is the favorites page'**
  String get favoritesPageContent;

  /// No description provided for @historyPageContent.
  ///
  /// In en, this message translates to:
  /// **'This is the history page'**
  String get historyPageContent;

  /// No description provided for @likesPageContent.
  ///
  /// In en, this message translates to:
  /// **'This is the likes page'**
  String get likesPageContent;

  /// No description provided for @userInfoPageContent.
  ///
  /// In en, this message translates to:
  /// **'This is the user info page'**
  String get userInfoPageContent;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'replies'**
  String get replies;

  /// No description provided for @expand.
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get expand;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All Tags'**
  String get allTags;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @noMoreComments.
  ///
  /// In en, this message translates to:
  /// **'No more comments'**
  String get noMoreComments;

  /// No description provided for @loadMoreReplies.
  ///
  /// In en, this message translates to:
  /// **'Load more replies'**
  String get loadMoreReplies;

  /// No description provided for @noVideoContent.
  ///
  /// In en, this message translates to:
  /// **'No video content available'**
  String get noVideoContent;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @fans.
  ///
  /// In en, this message translates to:
  /// **'Fans'**
  String get fans;

  /// No description provided for @noMoreVideos.
  ///
  /// In en, this message translates to:
  /// **'No more videos'**
  String get noMoreVideos;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @sortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get sortLatest;

  /// No description provided for @sortHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get sortHot;

  /// No description provided for @sortLike.
  ///
  /// In en, this message translates to:
  /// **'By Likes'**
  String get sortLike;

  /// No description provided for @sortFavorite.
  ///
  /// In en, this message translates to:
  /// **'By Favorites'**
  String get sortFavorite;

  /// No description provided for @sortComment.
  ///
  /// In en, this message translates to:
  /// **'By Comments'**
  String get sortComment;

  /// No description provided for @sortDuration.
  ///
  /// In en, this message translates to:
  /// **'By Duration'**
  String get sortDuration;

  /// No description provided for @intro.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get intro;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search videos / users / categories'**
  String get searchPlaceholder;

  /// No description provided for @loadingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading in progress'**
  String get loadingInProgress;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @postComment.
  ///
  /// In en, this message translates to:
  /// **'Post a comment'**
  String get postComment;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noMore.
  ///
  /// In en, this message translates to:
  /// **'No more'**
  String get noMore;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @moreMedia.
  ///
  /// In en, this message translates to:
  /// **'Contains more images/videos'**
  String get moreMedia;

  /// No description provided for @hasAudio.
  ///
  /// In en, this message translates to:
  /// **'Contains audio'**
  String get hasAudio;

  /// No description provided for @hasFile.
  ///
  /// In en, this message translates to:
  /// **'Contains file'**
  String get hasFile;

  /// No description provided for @unknownCategory.
  ///
  /// In en, this message translates to:
  /// **'Unknown category'**
  String get unknownCategory;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous user'**
  String get anonymousUser;

  /// No description provided for @alreadyFollowed.
  ///
  /// In en, this message translates to:
  /// **'Already followed'**
  String get alreadyFollowed;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @versionName.
  ///
  /// In en, this message translates to:
  /// **'Version Name'**
  String get versionName;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose a source'**
  String get chooseSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get bio;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @mustConnect.
  ///
  /// In en, this message translates to:
  /// **'You must be connected'**
  String get mustConnect;

  /// No description provided for @longVideo.
  ///
  /// In en, this message translates to:
  /// **'Long video'**
  String get longVideo;

  /// No description provided for @shortVideo.
  ///
  /// In en, this message translates to:
  /// **'Short video'**
  String get shortVideo;

  /// No description provided for @watchHistory.
  ///
  /// In en, this message translates to:
  /// **'Watch history'**
  String get watchHistory;

  /// No description provided for @qrCodeSaved.
  ///
  /// In en, this message translates to:
  /// **'QR code has been saved to the album'**
  String get qrCodeSaved;

  /// No description provided for @qrCodeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed, please check album/gallery permissions'**
  String get qrCodeSaveFailed;

  /// No description provided for @contentCopied.
  ///
  /// In en, this message translates to:
  /// **'Content copied'**
  String get contentCopied;

  /// No description provided for @myCredentials.
  ///
  /// In en, this message translates to:
  /// **'My credentials'**
  String get myCredentials;

  /// No description provided for @copyLoginCredentials.
  ///
  /// In en, this message translates to:
  /// **'Copy login credentials'**
  String get copyLoginCredentials;

  /// No description provided for @saveLoginCredentials.
  ///
  /// In en, this message translates to:
  /// **'Save login credentials'**
  String get saveLoginCredentials;

  /// No description provided for @saveAccountInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Please save your account information'**
  String get saveAccountInfoTitle;

  /// No description provided for @saveAccountInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'To avoid losing your account, please save the information below in time.'**
  String get saveAccountInfoDescription;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @saveAccountInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Save account'**
  String get saveAccountInfoButton;

  /// No description provided for @accountInfoSavedToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Account information has been saved to the album'**
  String get accountInfoSavedToAlbum;

  /// No description provided for @saveFailedTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Save failed, please try again later'**
  String get saveFailedTryAgainLater;

  /// No description provided for @screenshotSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Please take a screenshot'**
  String get screenshotSaveTitle;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @confirmClearingHistory.
  ///
  /// In en, this message translates to:
  /// **'Confirm clearing history?'**
  String get confirmClearingHistory;

  /// No description provided for @actionCanNotBeUndoneWhenClearingHistory.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to clear all chat messages?'**
  String get actionCanNotBeUndoneWhenClearingHistory;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @unreadMessage.
  ///
  /// In en, this message translates to:
  /// **'Unread message'**
  String get unreadMessage;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get item;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a message…'**
  String get enterMessage;

  /// No description provided for @followEachOther.
  ///
  /// In en, this message translates to:
  /// **'Follow each other'**
  String get followEachOther;

  /// No description provided for @pleaseEnterYourUsernameOrId.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username or ID'**
  String get pleaseEnterYourUsernameOrId;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start conversation'**
  String get startConversation;

  /// No description provided for @myFollows.
  ///
  /// In en, this message translates to:
  /// **'My follows'**
  String get myFollows;

  /// No description provided for @systemNotification.
  ///
  /// In en, this message translates to:
  /// **'System notification'**
  String get systemNotification;

  /// No description provided for @checkTheLatestSystemNotification.
  ///
  /// In en, this message translates to:
  /// **'Check the latest system messages'**
  String get checkTheLatestSystemNotification;

  /// No description provided for @noConversationFound.
  ///
  /// In en, this message translates to:
  /// **'No conversation found'**
  String get noConversationFound;

  /// No description provided for @groupChat.
  ///
  /// In en, this message translates to:
  /// **'Group chat'**
  String get groupChat;

  /// No description provided for @searchUsernameOrIdPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter username or ID to start searching'**
  String get searchUsernameOrIdPlaceholder;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get newMessage;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get all;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @watchEarnLiveMore.
  ///
  /// In en, this message translates to:
  /// **'Watch\nEarn\nLive\nMore'**
  String get watchEarnLiveMore;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get currentVersion;

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get latestVersion;

  /// No description provided for @newVersionAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version is available!'**
  String get newVersionAvailable;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @appUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Your application is up to date.'**
  String get appUpToDate;

  /// No description provided for @myFans.
  ///
  /// In en, this message translates to:
  /// **'My Fans'**
  String get myFans;

  /// No description provided for @userMissing.
  ///
  /// In en, this message translates to:
  /// **'User missing'**
  String get userMissing;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in.'**
  String get mustBeLoggedIn;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @reachedEnd.
  ///
  /// In en, this message translates to:
  /// **'Reached the end'**
  String get reachedEnd;

  /// No description provided for @systemEvent.
  ///
  /// In en, this message translates to:
  /// **'System Event'**
  String get systemEvent;

  /// No description provided for @botCommand.
  ///
  /// In en, this message translates to:
  /// **'Bot Command'**
  String get botCommand;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noUpdateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No update available'**
  String get noUpdateAvailable;

  /// No description provided for @phoneNumberTooShort.
  ///
  /// In en, this message translates to:
  /// **'The number must contain at least 8 digits'**
  String get phoneNumberTooShort;

  /// No description provided for @phoneNumberTooLong.
  ///
  /// In en, this message translates to:
  /// **'The number must contain at most 12 digits'**
  String get phoneNumberTooLong;

  /// No description provided for @underMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Under Maintenance'**
  String get underMaintenance;

  /// No description provided for @maintenanceWeb.
  ///
  /// In en, this message translates to:
  /// **'Our website is temporarily unavailable.\nWe are working hard to improve your experience.\nThank you for your patience.'**
  String get maintenanceWeb;

  /// No description provided for @maintenanceMobile.
  ///
  /// In en, this message translates to:
  /// **'Our mobile app is temporarily unavailable.\nWe are working hard to improve your experience.\nThank you for your patience.'**
  String get maintenanceMobile;

  /// No description provided for @maintenanceService.
  ///
  /// In en, this message translates to:
  /// **'Our service is temporarily unavailable.\nWe are working hard to improve your experience.\nThank you for your patience.'**
  String get maintenanceService;

  /// No description provided for @useBrowser.
  ///
  /// In en, this message translates to:
  /// **'Use the browser'**
  String get useBrowser;

  /// No description provided for @downloadApp.
  ///
  /// In en, this message translates to:
  /// **'Download the app'**
  String get downloadApp;

  /// No description provided for @quitApp.
  ///
  /// In en, this message translates to:
  /// **'Quit the app'**
  String get quitApp;

  /// No description provided for @noLanguagesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No languages available'**
  String get noLanguagesAvailable;

  /// No description provided for @availableLanguages.
  ///
  /// In en, this message translates to:
  /// **'Available Languages'**
  String get availableLanguages;

  /// No description provided for @downloadLanguages.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Languages'**
  String get downloadLanguages;

  /// No description provided for @errorLoadingDownloadedLanguages.
  ///
  /// In en, this message translates to:
  /// **'Error loading downloaded languages'**
  String get errorLoadingDownloadedLanguages;

  /// No description provided for @errorLoadingSelectedLanguages.
  ///
  /// In en, this message translates to:
  /// **'Error loading selected language'**
  String get errorLoadingSelectedLanguages;

  /// No description provided for @errorLoadingLanguages.
  ///
  /// In en, this message translates to:
  /// **'Error loading languages'**
  String get errorLoadingLanguages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
