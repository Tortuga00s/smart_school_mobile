
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // Login menggunakan Firebase Authentication
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Pengguna tidak ditemukan.');
    }

    // Mengambil profil berdasarkan UID Firebase
    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!document.exists || document.data() == null) {
      await _auth.signOut();
      throw Exception(
        'Profil pengguna belum terdaftar di Firestore.',
      );
    }

    final profile = document.data()!;

    final role = (profile['role'] ?? '')
        .toString()
        .toLowerCase();

    final status = (profile['status'] ?? '')
        .toString()
        .toLowerCase();

    if (status != 'active') {
      await _auth.signOut();
      throw Exception('Akun tidak aktif.');
    }

    if (role != 'teacher' && role != 'parent') {
      await _auth.signOut();
      throw Exception('Role pengguna tidak valid.');
    }

    return {
      ...profile,
      'uid': user.uid,
    };
  }

  // Logout Firebase
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
