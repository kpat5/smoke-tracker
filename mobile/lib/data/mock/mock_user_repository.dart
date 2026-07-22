import '../../models/user_profile.dart';
import '../repositories/user_repository.dart';
import 'mock_database.dart';

/// Mock [UserRepository] backed by [MockDatabase].
class MockUserRepository implements UserRepository {
  MockUserRepository(this._db);

  final MockDatabase _db;

  @override
  Future<UserProfile> getUser() async => _db.profile;

  @override
  Future<UserProfile> updateUser(UserProfile profile) async {
    _db.profile = profile;
    return profile;
  }
}
