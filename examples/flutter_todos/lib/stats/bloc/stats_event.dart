part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object> get props => [];
}

class StatsSubscriptionRequested extends StatsEvent {
  const StatsSubscriptionRequested();
}
