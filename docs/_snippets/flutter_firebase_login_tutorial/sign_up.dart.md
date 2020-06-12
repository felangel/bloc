```dart
Future<void> signUp({String email, String password}) async {
  return await _firebaseAuth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
}
```
