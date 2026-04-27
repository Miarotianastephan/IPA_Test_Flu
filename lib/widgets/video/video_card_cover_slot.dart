import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'video_card_cover.dart';

const double _webCoverActivationVisibleFraction = 0.2;
const double _mobileCoverActivationVisibleFraction = 0.08;
const double _coverPrefetchVisibleFraction = 0.55;

class VideoCardCoverSlot extends ConsumerStatefulWidget {
  final String videoId;
  final String coverUrl;
  final int videoType;
  final List<String> preloadCoverUrls;
  final double? fixedCoverAspectRatio;
  final bool useContentConstraintsForImage;
  final Widget? placeholder;
  final Widget? errorWidget;

  const VideoCardCoverSlot({
    super.key,
    required this.videoId,
    required this.coverUrl,
    required this.videoType,
    this.preloadCoverUrls = const [],
    this.fixedCoverAspectRatio,
    this.useContentConstraintsForImage = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  ConsumerState<VideoCardCoverSlot> createState() => _VideoCardCoverSlotState();
}

class _VideoCardCoverSlotState extends ConsumerState<VideoCardCoverSlot> {
  static const int _maxActivatedCoverUrls = 240;
  static final LinkedHashSet<String> _activatedCoverUrls =
      LinkedHashSet<String>();

  bool _coverActivated = false;
  bool _coverPrefetched = false;
  double _visibleFraction = 0;

  double get _activationVisibleFraction => kIsWeb
      ? _webCoverActivationVisibleFraction
      : _mobileCoverActivationVisibleFraction;

  @override
  void initState() {
    super.initState();
    _restoreActivationState();
  }

  @override
  void didUpdateWidget(covariant VideoCardCoverSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId ||
        oldWidget.coverUrl != widget.coverUrl ||
        oldWidget.videoType != widget.videoType) {
      _coverActivated = false;
      _coverPrefetched = false;
      _visibleFraction = 0;
      _restoreActivationState();
    }
  }

  void _restoreActivationState() {
    if (_activatedCoverUrls.remove(widget.coverUrl)) {
      _activatedCoverUrls.add(widget.coverUrl);
      _coverActivated = true;
    }
  }

  void _rememberActivatedCover() {
    _activatedCoverUrls.remove(widget.coverUrl);
    _activatedCoverUrls.add(widget.coverUrl);

    while (_activatedCoverUrls.length > _maxActivatedCoverUrls) {
      _activatedCoverUrls.remove(_activatedCoverUrls.first);
    }
  }

  void _scheduleCoverActivation() {
    if (_coverActivated || _visibleFraction < _activationVisibleFraction) {
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _coverActivated = true;
    });
    _rememberActivatedCover();
  }

  void _maybePrefetch() {
    if (_coverPrefetched ||
        widget.preloadCoverUrls.isEmpty ||
        _visibleFraction < _coverPrefetchVisibleFraction) {
      return;
    }

    _coverPrefetched = true;
    unawaited(warmVideoCardCovers(ref, widget.preloadCoverUrls));
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    _visibleFraction = info.visibleFraction;

    if (_visibleFraction <= 0) {
      return;
    }

    _scheduleCoverActivation();
    _maybePrefetch();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey('video-card-cover-${widget.videoId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: VideoCardCover(
        url: widget.coverUrl,
        videoType: widget.videoType,
        enabled: _coverActivated,
        fixedAspectRatio: widget.fixedCoverAspectRatio,
        useContentConstraintsForImage: widget.useContentConstraintsForImage,
        fit: BoxFit.cover,
        placeholder: widget.placeholder,
        errorWidget: widget.errorWidget,
      ),
    );
  }
}
