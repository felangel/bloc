```dart
Future<void> signInWithCredentials(String email, String password) {
  return _firebaseAuth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```
