import 'package:bloc/bloc.dart';

// We can extend `BlocObserver` and override `onChange` and and `onError`
// in order to handle state changes and errors from all Cubits.
class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(Cubit cubit, Change change) {
    print('${cubit.runtimeType} $change');
    super.onChange(cubit, change);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print(error);
    super.onError(cubit, error, stackTrace);
  }
}
