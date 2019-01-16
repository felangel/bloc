import 'package:equatable/equatable.dart';

abstract class GithubSearchEvent extends Equatable {}

class TextChanged extends GithubSearchEvent {
  final String text;

  TextChanged({this.text});

  @override
  String toString() => 'TextChanged { text: $text }';
}
