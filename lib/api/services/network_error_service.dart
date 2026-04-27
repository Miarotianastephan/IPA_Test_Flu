import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NetworkErrorService {
  static final NetworkErrorService _instance = NetworkErrorService._internal();

  factory NetworkErrorService() {
    return _instance;
  }

  NetworkErrorService._internal();

  Future<void> handleError(DioException error, VoidCallback onRetry) async {
    // Network error handling disabled
  }
}
