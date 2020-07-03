@TestOn('browser')

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:angular/angular.dart' show ChangeDetectorRef;

import 'package:angular_bloc/angular_bloc.dart';
import 'package:bloc/bloc.dart';

class MockChangeDetectorRef extends Mock implements ChangeDetectorRef {}

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

void main() {
  group('Stream', () {
    Bloc bloc;
    BlocPipe pipe;
    ChangeDetectorRef ref;

    setUp(() {
      bloc = CounterBloc();
      ref = MockChangeDetectorRef();
      pipe = BlocPipe(ref);
    });

    group('transform', () {
      test('should return initialState when subscribing to an bloc', () {
        expect(pipe.transform(bloc), 0);
      });
      test('should return the latest available value', () async {
        pipe.transform(bloc);
        bloc.add(CounterEvent.increment);
        Timer.run(expectAsync0(() {
          final dynamic res = pipe.transform(bloc);
          expect(res, 1);
        }));
      });

      test(
          'should return same value when nothing has changed '
          'since the last call', () async {
        pipe.transform(bloc);
        bloc.add(CounterEvent.increment);
        Timer.run(expectAsync0(() {
          pipe.transform(bloc);
          expect(pipe.transform(bloc), 1);
        }));
      });

      test(
          'should dispose of the existing subscription when '
          'subscribing to a new bloc', () async {
        pipe.transform(bloc);
        var newBloc = CounterBloc();
        expect(pipe.transform(newBloc), 0);
        // this should not affect the pipe
        bloc.add(CounterEvent.increment);
        Timer.run(expectAsync0(() {
          expect(pipe.transform(newBloc), 0);
        }));
      });
      test('should not dispose of existing subscription when Streams are equal',
          () async {
        // See https://github.com/dart-lang/angular2/issues/260
        final _bloc = CounterBloc();
        expect(pipe.transform(_bloc), 0);
        _bloc.add(CounterEvent.increment);
        Timer.run(expectAsync0(() {
          expect(pipe.transform(_bloc), 1);
        }));
      });
      test('should request a change detection check upon receiving a new value',
          () async {
        pipe.transform(bloc);
        bloc.add(CounterEvent.increment);
        Timer(const Duration(milliseconds: 10), expectAsync0(() {
          verify(ref.markForCheck()).called(2);
        }));
      });
    });
    group('ngOnDestroy', () {
      test('should do nothing when no subscription and not throw exception',
          () {
        pipe.ngOnDestroy();
      });
      test('should dispose of the existing subscription', () async {
        pipe.transform(bloc);
        pipe.ngOnDestroy();
        bloc.add(CounterEvent.increment);
        Timer.run(expectAsync0(() {
          expect(pipe.transform(bloc), 1);
        }));
      });
    });
  });
  group('null', () {
    test('should return null when given null', () {
      var pipe = BlocPipe(null);
      expect(pipe.transform(null), isNull);
    });
  });
}
