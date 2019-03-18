import 'package:bloc/bloc.dart';

/// Oversees all [Bloc]s and delegates responsibilities to the [BlocDelegate].
class BlocSupervisor {
  /// [BlocDelegate] which is notified when events occur in all [Bloc]s.
  BlocDelegate delegate;

  static final BlocSupervisor _singleton = BlocSupervisor._internal();

  factory BlocSupervisor() {
    return _singleton;
  }

  BlocSupervisor._internal();
}
