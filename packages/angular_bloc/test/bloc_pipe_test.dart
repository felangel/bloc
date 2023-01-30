@TestOn('browser')

import 'dart:async';

import 'package:angular_bloc/angular_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ngdart/angular.dart' show ChangeDetectorRef;
import 'package:test/test.dart';

class MockChangeDetectorRef extends Mock implements ChangeDetectorRef {}

abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
    on<Decrement>((event, emit) => emit(state - 1));
  }
}

void main() {
  group('Stream', () {
    late Bloc bloc;
    late BlocPipe pipe;
    late ChangeDetectorRef ref;

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
        bloc.add(Increment());
        Timer.run(expectAsync0(() {
          final dynamic res = pipe.transform(bloc);
          expect(res, 1);
        }));
      });

      test(
          'should return same value when nothing has changed '
          'since the last call', () async {
        pipe.transform(bloc);
        bloc.add(Increment());
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
        bloc.add(Increment());
        Timer.run(expectAsync0(() {
          expect(pipe.transform(newBloc), 0);
        }));
      });

      test('should not dispose of existing subscription when Streams are equal',
          () async {
        // See https://github.com/dart-lang/angular2/issues/260
        final _bloc = CounterBloc();
        expect(pipe.transform(_bloc), 0);
        _bloc.add(Increment());
        Timer.run(expectAsync0(() {
          expect(pipe.transform(_bloc), 1);
        }));
      });

      test('should request a change detection check upon receiving a new value',
          () async {
        pipe.transform(bloc);
        bloc.add(Increment());
        Timer(const Duration(milliseconds: 10), expectAsync0(() {
          verify(() => ref.markForCheck()).called(1);
        }));
      });
    });

    group('ngOnDestroy', () {
      test('should do nothing when no subscription and not throw exception',
          () {
        pipe.ngOnDestroy();
      });

      test('should dispose of the existing subscription', () async {
        pipe
          ..transform(bloc)
          ..ngOnDestroy();
        bloc.add(Increment());
        Timer.run(expectAsync0(() {
          expect(pipe.transform(bloc), 1);
        }));
      });
    });
  });
}
