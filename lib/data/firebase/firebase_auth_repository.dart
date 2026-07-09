import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    _validateEmail(email);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password,
    );
    return _fetchUserProfile(credential.user!.uid);
  }

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? ventureName,
  }) async {
    _validateEmail(email);
    if (fullName.trim().isEmpty) throw Exception('Full name is required.');
    if (role == UserRole.startup &&
        (ventureName == null || ventureName.trim().isEmpty)) {
      throw Exception('Venture name is required for startups.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.toLowerCase().trim(),
      password: password,
    );
    final uid = credential.user!.uid;

    final user = UserModel(
      id: uid,
      fullName: fullName.trim(),
      email: email.toLowerCase().trim(),
      role: role,
      ventureName: ventureName?.trim(),
      createdAt: DateTime.now(),
    );
    await _users.doc(uid).set(user.toMap());
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchUserProfile(firebaseUser.uid);
  }

  Future<void> updateProfile(UserModel updated) async {
    await _users.doc(updated.id).set(updated.toMap(), SetOptions(merge: true));
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) throw Exception('User profile not found.');
    final data = doc.data()!;
    data['id'] = uid;
    return UserModel.fromMap(data);
  }

  void _validateEmail(String email) {
    final lower = email.toLowerCase().trim();
    final isValid = AppConstants.allowedEmailDomains
        .any((domain) => lower.endsWith('@$domain'));
    if (!isValid) {
      throw Exception(
          'Only ALU emails are allowed (@alustudent.com or @alueducation.org).');
    }
  }
}
