
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IAuthService {
  Stream<String?> get authStateChanges;
  String? get currentUserId;
  bool get isAuthenticated;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  Future<void> sendEmailVerification();
  Future<bool> reloadEmailVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signInWithBiometrics();
  Future<void> signOut();

  Future<void> updateBloodType(String bloodType);
}

class VitaAuthService implements IAuthService {
  static final VitaAuthService instance = VitaAuthService._internal();

  factory VitaAuthService() => instance;

  VitaAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String currentUserName = '';
  String currentUserEmail = '';
  String currentUserPhone = '';
  String currentUserBloodType = 'Not Set';
  bool isNewAccount = false;

  static const List<String> validBloodTypes = [
    'A+', 'A-',
    'B+', 'B-',
    'AB+', 'AB-',
    'O+', 'O-',
  ];

  @override
  Stream<String?> get authStateChanges {
    return _auth.authStateChanges().map(
          (user) => user != null && user.emailVerified ? user.uid : null,
    );
  }

  @override
  String? get currentUserId {
    final user = _auth.currentUser;
    return user != null && user.emailVerified ? user.uid : null;
  }

  @override
  bool get isAuthenticated => currentUserId != null;

  @override
  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = fullName.trim();
    final cleanPhone = phone.trim();

    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      throw Exception('Name and phone are required.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    await user.updateDisplayName(cleanName);

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': cleanName,
      'email': cleanEmail,
      'phone': cleanPhone,
      'phoneVerified': false,
      'emailVerified': false,
      'bloodType': 'Not Set',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();

    currentUserName = cleanName;
    currentUserEmail = cleanEmail;
    currentUserPhone = cleanPhone;
    currentUserBloodType = 'Not Set';
    isNewAccount = true;
  }

  Future<void> _loadUserProfile(User user) async {
    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      throw Exception('User profile not found.');
    }

    final data = doc.data()!;

    currentUserName = data['fullName'] ?? user.displayName ?? '';
    currentUserEmail = data['email'] ?? user.email ?? '';
    currentUserPhone = data['phone'] ?? '';

    final savedBloodType = data['bloodType']?.toString() ?? 'Not Set';

    currentUserBloodType = validBloodTypes.contains(savedBloodType)
        ? savedBloodType
        : 'Not Set';
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Login failed.');
    }

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null) {
      throw Exception('User session expired.');
    }

    if (!refreshedUser.emailVerified) {
      await _auth.signOut();

      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Please verify your email before signing in.',
      );
    }

    await _loadUserProfile(refreshedUser);
    isNewAccount = false;
  }

  @override
  Future<void> updateBloodType(String bloodType) async {
    final cleanBloodType = bloodType.trim().toUpperCase();

    if (!validBloodTypes.contains(cleanBloodType)) {
      throw Exception('Invalid blood type.');
    }

    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'bloodType': cleanBloodType,
    });

    currentUserBloodType = cleanBloodType;
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No registered user found.');
    }

    await user.sendEmailVerification();
  }

  @override
  Future<bool> reloadEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    await user.reload();

    final refreshedUser = _auth.currentUser;

    if (refreshedUser == null || !refreshedUser.emailVerified) {
      return false;
    }

    await refreshedUser.getIdToken(true);
    await _loadUserProfile(refreshedUser);

    await _firestore.collection('users').doc(refreshedUser.uid).update({
      'emailVerified': true,
    });

    return true;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  @override
  Future<void> signInWithBiometrics() async {
    throw UnsupportedError('Biometrics are not connected yet.');
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();

    currentUserName = '';
    currentUserEmail = '';
    currentUserPhone = '';
    currentUserBloodType = 'Not Set';
    isNewAccount = false;
  }
}
