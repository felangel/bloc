abstract class GithubSearchEvent {}

class TextChanged extends GithubSearchEvent {
  final String text;

  TextChanged({this.text});

  @override
  String toString() => 'TextChanged { text: $text }';
}
