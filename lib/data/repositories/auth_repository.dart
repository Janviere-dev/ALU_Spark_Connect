import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../mock/mock_data.dart';
import '../models/user_model.dart';

// Firebase implementation: replace MockDB calls with FirebaseAuth + Firestore
class AuthRepository {
  final MockDB _db = MockDB();
  final _uuid = const Uuid();

  Future<UserModel> signIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _validateEmail(email);

    final user = _db.findUserByEmail(email);
    if (user == null) throw Exception('No account found with this email.');
    if (password.length < 6) throw Exception('Invalid password.');

    _db.setCurrentUser(user);
    return user;
  }

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? ventureName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _validateEmail(email);

    if (_db.findUserByEmail(email) != null) {
      throw Exception('An account with this email already exists.');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters.');
    }
    if (fullName.trim().isEmpty) {
      throw Exception('Full name is required.');
    }
    if (role == UserRole.startup && (ventureName == null || ventureName.trim().isEmpty)) {
      throw Exception('Venture name is required for startups.');
    }

    final user = UserModel(
      id: _uuid.v4(),
      fullName: fullName.trim(),
      email: email.toLowerCase().trim(),
      role: role,
      ventureName: ventureName?.trim(),
      skills: const [],
      focusAreas: const [],
      onboardingComplete: false,
      createdAt: DateTime.now(),
    );

    _db.addUser(user);
    _db.setCurrentUser(user);
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.setCurrentUser(null);
  }

  UserModel? getCurrentUser() => _db.currentUser;

  Future<void> updateProfile(UserModel updated) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _db.updateUser(updated);
  }

  void _validateEmail(String email) {
    final lower = email.toLowerCase().trim();
    final isValid = AppConstants.allowedEmailDomains.any((domain) => lower.endsWith('@$domain'));
    if (!isValid) {
      throw Exception(
        'Only ALU emails are allowed (@alustudent.com or @alueducation.org).',
      );
    }
  }
}
