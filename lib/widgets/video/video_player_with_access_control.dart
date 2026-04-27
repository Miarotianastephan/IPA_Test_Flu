import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/content_access_response.dart';
import '../../models/video_info.dart';
import '../../provider/video_preview_provider.dart';
import '../../services/content_access_service.dart';
import '../payment/content_lock_overlay.dart';
import '../payment/preview_timer_overlay.dart';
import '../video_player_screen.dart';

/// Video player wrapper with content access control and preview support
class VideoPlayerWithAccessControl extends ConsumerStatefulWidget {
  final VideoInfo video;
  final String videoUrl;
  final bool isNetwork;

  const VideoPlayerWithAccessControl({
    super.key,
    required this.video,
    required this.videoUrl,
    this.isNetwork = true,
  });

  @override
  ConsumerState<VideoPlayerWithAccessControl> createState() =>
      _VideoPlayerWithAccessControlState();
}

class _VideoPlayerWithAccessControlState
    extends ConsumerState<VideoPlayerWithAccessControl> {
  ContentAccessResponse? _accessResponse;
  bool _isCheckingAccess = true;
  bool _isInPreviewMode = false;
  bool _hasConsumedPreview = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final contentAccessService = ref.read(contentAccessServiceProvider);

    setState(() {
      _isCheckingAccess = true;
    });

    try {
      final response = await contentAccessService.checkVideoAccess(
        widget.video.id,
      );

      if (mounted) {
        setState(() {
          _accessResponse = response;
          _isCheckingAccess = false;
        });

        // If no access and has previews, show option
        if (!response.hasAccess && response.hasPreviewsAvailable) {
          _showPreviewOption();
        } else if (!response.hasAccess) {
          _showLockOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingAccess = false;
        });
      }
    }
  }

  void _showPreviewOption() {
    // Show dialog asking if user wants to use a preview
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Preview Available'),
        content: Text(
          'You have ${_accessResponse!.previewsRemaining} free previews remaining. '
          'Watch ${_accessResponse!.previewDuration}s of this video?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showLockOverlay();
            },
            child: const Text('Unlock Full Video'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startPreview();
            },
            child: const Text('Use Preview'),
          ),
        ],
      ),
    );
  }

  void _showLockOverlay() {
    if (_accessResponse == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ContentLockOverlay(
        accessResponse: _accessResponse!,
        video: widget.video,
        onPurchaseSuccess: () {
          // Refresh access after purchase
          _checkAccess();
        },
      ),
    );
  }

  Future<void> _startPreview() async {
    if (_accessResponse == null || !_accessResponse!.hasPreviewsAvailable) {
      return;
    }

    // Record preview usage
    if (!_hasConsumedPreview) {
      final success = await ref
          .read(videoPreviewProvider.notifier)
          .recordPreview(widget.video.id);

      if (success) {
        setState(() {
          _isInPreviewMode = true;
          _hasConsumedPreview = true;
        });
      }
    } else {
      setState(() {
        _isInPreviewMode = true;
      });
    }
  }

  void _onPreviewExpired() {
    setState(() {
      _isInPreviewMode = false;
    });

    // Show lock overlay after preview expires
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showLockOverlay();
      }
    });
  }

  void _onSkipPreview() {
    setState(() {
      _isInPreviewMode = false;
    });
    _showLockOverlay();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAccess) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If has access or in preview mode, show player
    if (_accessResponse?.hasAccess == true || _isInPreviewMode) {
      return Stack(
        children: [
          VideoPlayerScreen(
            videoUrl: widget.videoUrl,
            isNetwork: widget.isNetwork,
          ),
          // Show preview timer if in preview mode
          if (_isInPreviewMode && _accessResponse != null)
            PreviewTimerOverlay(
              durationSeconds: _accessResponse!.previewDuration ?? 30,
              onPreviewExpired: _onPreviewExpired,
              onSkipPreview: _onSkipPreview,
            ),
        ],
      );
    }

    // No access - show lock overlay
    return Scaffold(
      body: Stack(
        children: [
          // Show blurred thumbnail or placeholder
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(widget.video.cover),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Lock overlay
          if (_accessResponse != null)
            ContentLockOverlay(
              accessResponse: _accessResponse!,
              video: widget.video,
              onPurchaseSuccess: () {
                _checkAccess();
              },
            ),
        ],
      ),
    );
  }
}
