```dart
Future<bool> isSignedIn() async {
  final currentUser = await _firebaseAuth.currentUser();
  return currentUser != null;
}

Future<String> getUser() async {
  return (await _firebaseAuth.currentUser()).email;
}
```
