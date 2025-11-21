import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/userinfo.dart';

final currentUserProvider = StateProvider<UserInfo?>((ref) => null);
