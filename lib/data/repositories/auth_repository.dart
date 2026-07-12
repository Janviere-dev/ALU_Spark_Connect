import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<UserModel> signIn({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    _validateEmail(email, role: role);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      return _fetchProfile(credential.user!.uid, role: role);
    } on FirebaseAuthException catch (e) {
      throw Exception(_authMessage(e.code));
    }
  }

  Future<UserModel> signUp({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? ventureName,
    String? location,
    String? docsLink,
  }) async {
    _validateEmail(email, role: role);
    if (fullName.trim().isEmpty) throw Exception('Full name is required.');
    if (role == UserRole.startup) {
      if (ventureName == null || ventureName.trim().isEmpty) {
        throw Exception('Venture name is required for startups.');
      }
      if (docsLink == null || docsLink.trim().isEmpty) {
        throw Exception('Please paste your verification documents link.');
      }
    }

    UserCredential? credential;
    String uid;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      uid = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        throw Exception(_authMessage(e.code));
      }
      // Same email — sign in and create a secondary profile for the new role
      try {
        final signInCred = await _auth.signInWithEmailAndPassword(
          email: email.toLowerCase().trim(),
          password: password,
        );
        uid = signInCred.user!.uid;
      } on FirebaseAuthException catch (e2) {
        throw Exception(_authMessage(e2.code));
      }
      final primaryDoc = await _users.doc(uid).get();
      if (primaryDoc.exists) {
        final existingRole = primaryDoc.data()!['role'] as String?;
        if (existingRole == role.name) {
          throw Exception('You already have a ${role.name} account with this email.');
        }
      }
      final secondaryId = '${uid}_${role.name}';
      final secondaryUser = UserModel(
        id: secondaryId,
        fullName: fullName.trim(),
        email: email.toLowerCase().trim(),
        role: role,
        ventureName: ventureName?.trim(),
        location: location?.trim().isEmpty == true ? null : location?.trim(),
        docsLink: docsLink?.trim(),
        status: role == UserRole.startup ? 'pending' : null,
        createdAt: DateTime.now(),
      );
      final map = secondaryUser.toMap();
      map['authUid'] = uid;
      await _users.doc(secondaryId).set(map);
      return secondaryUser;
    }

    final user = UserModel(
      id: uid,
      fullName: fullName.trim(),
      email: email.toLowerCase().trim(),
      role: role,
      ventureName: ventureName?.trim(),
      location: location?.trim().isEmpty == true ? null : location?.trim(),
      docsLink: docsLink?.trim(),
      status: role == UserRole.startup ? 'pending' : null,
      createdAt: DateTime.now(),
    );
    await _users.doc(uid).set(user.toMap());
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    try {
      return await _fetchProfile(firebaseUser.uid);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateProfile(UserModel updated) async {
    await _users.doc(updated.id).set(updated.toMap(), SetOptions(merge: true));
  }

  Future<UserModel> _fetchProfile(String uid, {UserRole? role}) async {
    final doc = await _users.doc(uid).get();

    // Admin check on primary document
    if (doc.exists) {
      final data = doc.data()!;
      final primaryRole = UserRole.values.firstWhere((r) => r.name == data['role']);
      if (primaryRole == UserRole.admin) {
        data['id'] = uid;
        return UserModel.fromMap(data);
      }
    }

    // Admin check on secondary _student document (handles admins who originally
    // signed up as students — their profile lives at users/{uid}_student)
    final studentSecondary = await _users.doc('${uid}_student').get();
    if (studentSecondary.exists) {
      final data = studentSecondary.data()!;
      final secRole = UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.student,
      );
      if (secRole == UserRole.admin) {
        data['id'] = '${uid}_student';
        return UserModel.fromMap(data);
      }
    }

    // Normal role-based routing
    if (doc.exists) {
      final data = doc.data()!;
      final primaryRole = UserRole.values.firstWhere((r) => r.name == data['role']);
      if (role == null || primaryRole == role) {
        data['id'] = uid;
        return UserModel.fromMap(data);
      }
    }
    if (role != null) {
      final secondaryId = '${uid}_${role.name}';
      final secondaryDoc = await _users.doc(secondaryId).get();
      if (secondaryDoc.exists) {
        final data = secondaryDoc.data()!;
        data['id'] = secondaryId;
        return UserModel.fromMap(data);
      }
    }
    if (!doc.exists) throw Exception('User profile not found.');
    final data = doc.data()!;
    data['id'] = uid;
    return UserModel.fromMap(data);
  }

  String _authMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      default:
        return 'Authentication error ($code). Please try again.';
    }
  }

  void _validateEmail(String email, {UserRole? role}) {
    if (role == UserRole.admin) return;
    final lower = email.toLowerCase().trim();
    if (role == UserRole.startup) {
      final isValid = AppConstants.startupEmailDomains
          .any((domain) => lower.endsWith('@$domain'));
      if (!isValid) {
        throw Exception(
            'Startups must use an ALU email (@alueducation.com) or Gmail (testing only).');
      }
    } else {
      final isValid = AppConstants.allowedEmailDomains
          .any((domain) => lower.endsWith('@$domain'));
      if (!isValid) {
        throw Exception(
            'Only ALU emails are allowed (@alustudent.com or @alueducation.com).');
      }
    }
  }
}
