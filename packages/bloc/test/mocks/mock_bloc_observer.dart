import 'package:bloc/bloc.dart';

class OnCreateCall {
  const OnCreateCall(this.cubit);

  final Cubit cubit;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnCreateCall && o.cubit == cubit;
  }

  @override
  int get hashCode => cubit.hashCode;
}

class OnChangeCall {
  const OnChangeCall(this.cubit, this.change);

  final Change change;
  final Cubit cubit;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnChangeCall && o.change == change && o.cubit == cubit;
  }

  @override
  int get hashCode => change.hashCode ^ cubit.hashCode;
}

class OnTransitionCall {
  const OnTransitionCall(this.bloc, this.transition);

  final Bloc bloc;
  final Transition transition;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnTransitionCall &&
        o.bloc == bloc &&
        o.transition == transition;
  }

  @override
  int get hashCode => bloc.hashCode ^ transition.hashCode;
}

class OnEventCall {
  const OnEventCall(this.bloc, this.event);

  final Bloc bloc;
  final Object? event;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnEventCall && o.bloc == bloc && o.event == event;
  }

  @override
  int get hashCode => bloc.hashCode ^ event.hashCode;
}

class OnErrorCall {
  const OnErrorCall(this.cubit, this.error, this.stackTrace);

  final Cubit cubit;
  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnErrorCall &&
        o.cubit == cubit &&
        o.error == error &&
        o.stackTrace == stackTrace;
  }

  @override
  int get hashCode => cubit.hashCode ^ error.hashCode ^ stackTrace.hashCode;
}

class OnCloseCall {
  const OnCloseCall(this.cubit);

  final Cubit cubit;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnCloseCall && o.cubit == cubit;
  }

  @override
  int get hashCode => cubit.hashCode;
}

class MockBlocObserver implements BlocObserver {
  final onCreateCalls = <OnCreateCall>[];
  final onChangeCalls = <OnChangeCall>[];
  final onTransitionCalls = <OnTransitionCall>[];
  final onEventCalls = <OnEventCall>[];
  final onErrorCalls = <OnErrorCall>[];
  final onCloseCalls = <OnCloseCall>[];

  @override
  void onCreate(Cubit cubit) {
    onCreateCalls.add(OnCreateCall(cubit));
  }

  @override
  void onChange(Cubit cubit, Change change) {
    onChangeCalls.add(OnChangeCall(cubit, change));
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    onTransitionCalls.add(OnTransitionCall(bloc, transition));
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    onEventCalls.add(OnEventCall(bloc, event));
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace? stackTrace) {
    onErrorCalls.add(OnErrorCall(cubit, error, stackTrace));
  }

  @override
  void onClose(Cubit cubit) {
    onCloseCalls.add(OnCloseCall(cubit));
  }
}
