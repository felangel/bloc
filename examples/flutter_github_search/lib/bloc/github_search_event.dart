import 'package:equatable/equatable.dart';

abstract class GithubSearchEvent extends Equatable {
  GithubSearchEvent([List props = const []]) : super(props);
}

class TextChanged extends GithubSearchEvent {
  final String text;

  TextChanged({this.text}) : super([text]);

  @override
  String toString() => 'TextChanged { text: $text }';
}
