```dart
Future<void> signOut() async {
  return Future.wait([
    _firebaseAuth.signOut(),
    _googleSignIn.signOut(),
  ]);
}
```
