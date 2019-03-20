import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  Future<FirebaseUser> getInitialSignInState() {
    return FirebaseAuth.instance.onAuthStateChanged.first;
  }

  Future<FirebaseUser> sigInWithGoogle() async {
    FirebaseAuth _instance = FirebaseAuth.instance;
    //Signin to google
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //Signin to Firebase and pass on the google credential
    final FirebaseUser user =
        await _instance.signInWithCredential(credential).then((fbUser) {
      assert(fbUser.email != null);
      assert(fbUser.displayName != null);
      return fbUser;
    }).catchError((e) {
      print(e.details);
    });
    return user;
  }

  Future signOutFromGoogle() {
    GoogleSignIn().signOut();
    return FirebaseAuth.instance.signOut();
  }
}
