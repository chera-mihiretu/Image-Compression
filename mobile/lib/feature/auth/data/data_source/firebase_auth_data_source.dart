import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/feature/auth/domain/entity/user_entity.dart';

class FirebaseAuthDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  FirebaseAuthDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  Stream<AppUser?> authStateChanges() {
    return firebaseAuth.authStateChanges().map((fb.User? user) {
      if (user == null) return null;
      return AppUser(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
      );
    });
  }

  Future<AppUser> signInWithGoogle() async {
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Sign in aborted by user');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    final userCred = await firebaseAuth.signInWithCredential(credential);
    final user = userCred.user!;
    return AppUser(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }
}
