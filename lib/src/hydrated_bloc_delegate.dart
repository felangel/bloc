import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// A specialized `BlocDelegate` which handles persisting state changes
/// transparently and asynchronously.
class HydratedBlocDelegate extends BlocDelegate {
  /// Instance of `HydratedBlocState` used to persist states.
  HydratedBlocStorage storage;

  HydratedBlocDelegate(this.storage);

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    final dynamic state = transition.nextState;
    storage.write(
      bloc.runtimeType.toString(),
      (bloc as HydratedBloc).toJson(state),
    );
  }
}
