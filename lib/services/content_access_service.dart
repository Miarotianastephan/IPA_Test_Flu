import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/content_access_response.dart';
import '../provider/api_provider.dart';

/// Content access service to check if user can access content
class ContentAccessService {
  final Ref ref;

  ContentAccessService(this.ref);

  /// Check if user has access to a video
  Future<ContentAccessResponse> checkVideoAccess(String videoId) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      final response = await paymentService.checkContentAccess(
        contentType: 'long_video',
        contentId: videoId,
      );

      if (response.data != null) {
        return response.data!;
      }

      // Default: no access, payment required
      return ContentAccessResponse(
        hasAccess: false,
        reason: 'payment_required',
      );
    } catch (e) {
      debugPrint('Failed to check video access: $e');
      // On error, assume payment required
      return ContentAccessResponse(hasAccess: false, reason: 'error');
    }
  }

  /// Check if user has access to an audio
  Future<ContentAccessResponse> checkAudioAccess(String audioId) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      final response = await paymentService.checkContentAccess(
        contentType: 'audio',
        contentId: audioId,
      );

      if (response.data != null) {
        return response.data!;
      }

      return ContentAccessResponse(
        hasAccess: false,
        reason: 'payment_required',
      );
    } catch (e) {
      debugPrint('Failed to check audio access: $e');
      return ContentAccessResponse(hasAccess: false, reason: 'error');
    }
  }

  /// Check if user has access to a post
  Future<ContentAccessResponse> checkPostAccess(String postId) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      final response = await paymentService.checkContentAccess(
        contentType: 'posts',
        contentId: postId,
      );

      if (response.data != null) {
        return response.data!;
      }

      return ContentAccessResponse(
        hasAccess: false,
        reason: 'payment_required',
      );
    } catch (e) {
      debugPrint('Failed to check post access: $e');
      return ContentAccessResponse(hasAccess: false, reason: 'error');
    }
  }

  /// Generic check for any content type
  Future<ContentAccessResponse> checkContentAccess({
    required String contentType,
    required String contentId,
  }) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      final response = await paymentService.checkContentAccess(
        contentType: contentType,
        contentId: contentId,
      );

      if (response.data != null) {
        return response.data!;
      }

      return ContentAccessResponse(
        hasAccess: false,
        reason: 'payment_required',
      );
    } catch (e) {
      debugPrint('Failed to check content access: $e');
      return ContentAccessResponse(hasAccess: false, reason: 'error');
    }
  }
}

/// Content access service provider
final contentAccessServiceProvider = Provider<ContentAccessService>((ref) {
  return ContentAccessService(ref);
});
