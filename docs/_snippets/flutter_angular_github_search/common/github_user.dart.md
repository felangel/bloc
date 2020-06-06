```dart
class GithubUser {
  final String login;
  final String avatarUrl;

  const GithubUser({this.login, this.avatarUrl});

  static GithubUser fromJson(dynamic json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }
}
```
