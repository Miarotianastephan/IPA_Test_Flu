enum AdPlacement {
  // Video
  videoFeedBanner('videoFeedBanner'),
  videoFeedInFeed('videoFeedInFeed'),
  videoPauseFullScreen('videoPauseFullScreen'),
  videoBottomBanner('videoBottomBanner'),
  videoPreRoll('videoPreRoll'),

  // Feed
  communityFeed('communityFeed'),
  communityTopBanner('communityTopBanner'),
  communityInlineSmall('communityInlineSmall'),
  communityLarge('communityLarge'),

  // Chat
  chatTopBanner('chatTopBanner'),
  chatBubble('chatBubble'),
  chatCTAButton('chatCTAButton'),
  chatList('chatList'),
  chatInputRecommendation('chatInputRecommendation'),

  // Status
  systemLoading('systemLoading'),
  systemNetworkError('systemNetworkError'),
  systemOffline('systemOffline'),

  // Open Screen
  openScreen('openScreen'),

  // Activity
  popupDaily('popupDaily'),
  popupAfterNVideos('popupAfterNVideos'),
  popupActivity('popupActivity'),
  popupExit('popupExit'),
  popupRedirect('popupRedirect'),
  activityScreen('activityScreen'),
  activityPopup('activityPopup'),
  triggeredScroll('triggeredScroll'),
  triggeredView('triggeredView'),
  triggeredStay('triggeredStay'),
  triggeredLike('triggeredLike'),
  triggeredComment('triggeredComment'),
  triggeredShare('triggeredShare'),
  triggeredPageVisit('triggeredPageVisit'),
  triggeredChatInteraction('triggeredChatInteraction'),
  redirectApp('redirectApp'),
  redirectRewarded('redirectRewarded'),
  redirectOfferwall('redirectOfferwall');

  final String code;
  const AdPlacement(this.code);
}
