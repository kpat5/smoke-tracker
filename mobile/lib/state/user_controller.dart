import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'providers.dart';

/// Loads and updates the current [UserProfile].
class UserController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() => ref.watch(userRepositoryProvider).getUser();

  /// Persists [profile] and reflects it in state.
  Future<void> save(UserProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(userRepositoryProvider).updateUser(profile),
    );
  }
}

final userProfileProvider = AsyncNotifierProvider<UserController, UserProfile>(
  UserController.new,
);
