import 'package:equatable/equatable.dart';

sealed class GithubSearchEvent extends Equatable {
  const GithubSearchEvent();
}

final class TextChanged extends GithubSearchEvent {
  const TextChanged({required this.text});

  final String text;

  @override
  List<Object> get props => [text];

  @override
  String toString() => 'TextChanged { text: $text }';
}

final class NextPageRequested extends GithubSearchEvent {
  const NextPageRequested();

  @override
  List<Object> get props => [];
}

final class Refreshed extends GithubSearchEvent {
  const Refreshed();

  @override
  List<Object> get props => [];
}
