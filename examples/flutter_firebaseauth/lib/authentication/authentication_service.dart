import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  Future<FirebaseUser> getInitialSignInState() {
    return FirebaseAuth.instance.onAuthStateChanged.first;
  }

  Future<FirebaseUser> signInWithGoogle() async {
    FirebaseAuth _instance = FirebaseAuth.instance;
    //SignIn to google
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //SignIn to Firebase and pass on the google credential
    final FirebaseUser user =
        await _instance.signInWithCredential(credential).then((fbUser) {
      return fbUser;
    }).catchError((e) {
      print(e.details);
    });
    return user;
  }

  Future signOutFromGoogle() async {
    await GoogleSignIn().signOut();
    return FirebaseAuth.instance.signOut();
  }
}
