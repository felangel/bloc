import '../bloc.dart';

/// Oversees all [bloc]s and delegates responsibilities to the [BlocDelegate].
class BlocSupervisor {
  /// [BlocDelegate] which is notified when events occur in all [bloc]s.
  BlocDelegate _delegate = BlocDelegate();

  BlocSupervisor._();

  static final BlocSupervisor _instance = BlocSupervisor._();

  /// [BlocDelegate] getter which returns the singleton [BlocSupervisor]
  /// instance's [BlocDelegate].
  static BlocDelegate get delegate => _instance._delegate;

  /// [BlocDelegate] setter which sets the singleton [BlocSupervisor]
  /// instance's [BlocDelegate].
  static set delegate(BlocDelegate d) {
    _instance._delegate = d ?? BlocDelegate();
  }
}
