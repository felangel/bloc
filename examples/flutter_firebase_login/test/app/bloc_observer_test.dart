// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_firebase_login/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeBloc extends Fake implements Bloc<Object, Object> {}

class FakeCubit extends Fake implements Cubit<Object> {}

class FakeEvent extends Fake implements Object {}

class FakeState extends Fake implements Object {}

class FakeStackTrace extends Fake implements StackTrace {}

class FakeChange extends Fake implements Change<Object> {}

class FakeTransition extends Fake implements Transition<Object, Object> {}

void main() {
  group('AppBlocObserver', () {
    setUp(logs.clear);

    test(
      'onEvent prints event',
      overridePrint(() {
        final bloc = FakeBloc();
        final event = FakeEvent();
        AppBlocObserver().onEvent(bloc, event);
        expect(logs, equals(['$event']));
      }),
    );

    test(
      'onError prints error',
      overridePrint(() {
        final bloc = FakeBloc();
        final error = Object();
        final stackTrace = FakeStackTrace();
        AppBlocObserver().onError(bloc, error, stackTrace);
        expect(logs, equals(['$error']));
      }),
    );

    test(
      'onChange prints change',
      overridePrint(() {
        final cubit = FakeCubit();
        final change = FakeChange();
        AppBlocObserver().onChange(cubit, change);
        expect(logs, equals(['$change']));
      }),
    );

    test(
      'onTransition prints transition',
      overridePrint(() {
        final bloc = FakeBloc();
        final transition = FakeTransition();
        AppBlocObserver().onTransition(bloc, transition);
        expect(logs, equals(['$transition']));
      }),
    );
  });
}

final logs = <String>[];

void Function() overridePrint(void Function() testFn) {
  return () {
    final spec = ZoneSpecification(
      print: (_, __, ___, String msg) => logs.add(msg),
    );
    return Zone.current.fork(specification: spec).run<void>(testFn);
  };
}
