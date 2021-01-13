import 'package:bloc/bloc.dart';

class OnCreateCall {
  const OnCreateCall(this.bloc);

  final Bloc bloc;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnCreateCall && o.bloc == bloc;
  }

  @override
  int get hashCode => bloc.hashCode;
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
  const OnErrorCall(this.bloc, this.error, this.stackTrace);

  final Bloc bloc;
  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnErrorCall &&
        o.bloc == bloc &&
        o.error == error &&
        o.stackTrace == stackTrace;
  }

  @override
  int get hashCode => bloc.hashCode ^ error.hashCode ^ stackTrace.hashCode;
}

class OnCloseCall {
  const OnCloseCall(this.bloc);

  final Bloc bloc;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OnCloseCall && o.bloc == bloc;
  }

  @override
  int get hashCode => bloc.hashCode;
}

class MockBlocObserver implements BlocObserver {
  final onCreateCalls = <OnCreateCall>[];
  final onTransitionCalls = <OnTransitionCall>[];
  final onEventCalls = <OnEventCall>[];
  final onErrorCalls = <OnErrorCall>[];
  final onCloseCalls = <OnCloseCall>[];

  @override
  void onCreate(Bloc bloc) {
    onCreateCalls.add(OnCreateCall(bloc));
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
  void onError(Bloc bloc, Object error, StackTrace? stackTrace) {
    onErrorCalls.add(OnErrorCall(bloc, error, stackTrace));
  }

  @override
  void onClose(Bloc bloc) {
    onCloseCalls.add(OnCloseCall(bloc));
  }
}
