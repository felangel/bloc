import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class ProfileState extends Equatable {
  const ProfileState._({@required this.count}) : assert(count != null);

  factory ProfileState.initial() => ProfileState._(count: 0);

  final int count;
  // Other profile props you might need...

  @override
  List<Object> get props => <Object>[count];

  // ? Convenience method if we would have multiple props.
  ProfileState copyWith({int count}) => ProfileState._(
        count: count ?? this.count,
      );

  @override
  String toString() {
    return '$runtimeType $count';
  }
}
