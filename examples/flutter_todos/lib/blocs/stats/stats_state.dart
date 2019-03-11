import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class StatsState extends Equatable {
  StatsState([List props = const []]) : super(props);
}

class StatsLoading extends StatsState {
  @override
  String toString() => 'StatsLoading';
}

class StatsLoaded extends StatsState {
  final int numActive;
  final int numCompleted;

  StatsLoaded(this.numActive, this.numCompleted)
      : super([numActive, numCompleted]);

  @override
  String toString() {
    return 'StatsLoaded { numActive: $numActive, numCompleted: $numCompleted }';
  }
}
