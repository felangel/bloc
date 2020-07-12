import 'package:bloc/bloc.dart';

import 'hydrated_cubit.dart';
import 'hydrated_storage.dart';

/// {@template hydrated_bloc}
/// Specialized [Bloc] which handles initializing the [Bloc] state
/// based on the persisted state. This allows state to be persisted
/// across hot restarts as well as complete app restarts.
/// {@endtemplate}
abstract class HydratedBloc<Event, State> extends Bloc<Event, State>
    with HydratedMixin {
  /// {@macro hydrated_bloc}
  HydratedBloc(State state) : super(state) {
    init();
  }

  /// Setter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Bloc] state.
  static set storage(Storage storage) {
    HydratedMixin.storage = storage;
  }

  /// Getter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Bloc] state.
  static Storage get storage => HydratedMixin.storage;
}
