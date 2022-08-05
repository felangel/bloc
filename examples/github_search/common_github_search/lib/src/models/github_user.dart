class GithubUser {
  const GithubUser({
    required this.login,
    required this.avatarUrl,
  });

  factory GithubUser.fromJson(Map<String, dynamic> json) {
    return GithubUser(
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
    );
  }

  final String login;
  final String avatarUrl;
}
