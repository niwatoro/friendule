import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

import 'firestore.dart';

class AuthenticationService {
  final _firebaseAuth = auth.FirebaseAuth.instance;
  final _firestoreService = FirestoreService();

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;

    final credential = auth.GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
    _firestoreService.signIn();
  }

  Future<void> signInWithApple() async {
    final appleProvider = auth.AppleAuthProvider();
    await _firebaseAuth.signInWithProvider(appleProvider);
    _firestoreService.signIn();
  }

  String? getCurrentUserId() {
    if (getIsUserSignedIn()) {
      return _firebaseAuth.currentUser!.uid;
    } else {
      signOut();
    }
    return null;
  }

  bool getIsUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> getFcmToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  Future<void> updateFcmToken(String token) async {
    await _firestoreService.updateFcmToken(token);
  }
}
