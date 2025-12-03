import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/userinfo.dart';

final currentVideoUserProvider = StateProvider<UserInfo?>((ref) => null);
