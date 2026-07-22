import '../../models/user_profile.dart';

/// Reads and updates the user's profile.
///
/// Backed by mock data for now; a future HTTP implementation maps onto
/// `GET /user` and `PUT /user` with no change to callers.
abstract interface class UserRepository {
  Future<UserProfile> getUser();

  Future<UserProfile> updateUser(UserProfile profile);
}
