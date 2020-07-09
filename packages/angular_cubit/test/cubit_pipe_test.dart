@TestOn('browser')

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:angular/angular.dart' show ChangeDetectorRef;

import 'package:angular_cubit/angular_cubit.dart';
import 'package:cubit/cubit.dart';

class MockChangeDetectorRef extends Mock implements ChangeDetectorRef {}

enum CounterEvent { increment, decrement }

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

void main() {
  group('Stream', () {
    CounterCubit cubit;
    CubitPipe pipe;
    ChangeDetectorRef ref;

    setUp(() {
      cubit = CounterCubit();
      ref = MockChangeDetectorRef();
      pipe = CubitPipe(ref);
    });

    group('transform', () {
      test('should return initialState when subscribing to an cubit', () {
        expect(pipe.transform(cubit), 0);
      });
      test('should return the latest available value', () async {
        pipe.transform(cubit);
        cubit.increment();
        Timer.run(expectAsync0(() {
          final dynamic res = pipe.transform(cubit);
          expect(res, 1);
        }));
      });

      test(
          'should return same value when nothing has changed '
          'since the last call', () async {
        pipe.transform(cubit);
        cubit.increment();
        Timer.run(expectAsync0(() {
          pipe.transform(cubit);
          expect(pipe.transform(cubit), 1);
        }));
      });

      test(
          'should dispose of the existing subscription when '
          'subscribing to a new cubit', () async {
        pipe.transform(cubit);
        var newCubit = CounterCubit();
        expect(pipe.transform(newCubit), 0);
        // this should not affect the pipe
        cubit.increment();
        Timer.run(expectAsync0(() {
          expect(pipe.transform(newCubit), 0);
        }));
      });
      test('should not dispose of existing subscription when Streams are equal',
          () async {
        // See https://github.com/dart-lang/angular2/issues/260
        final _cubit = CounterCubit();
        expect(pipe.transform(_cubit), 0);
        _cubit.increment();
        Timer.run(expectAsync0(() {
          expect(pipe.transform(_cubit), 1);
        }));
      });
      test('should request a change detection check upon receiving a new value',
          () async {
        pipe.transform(cubit);
        await Future<void>.delayed(Duration.zero);
        cubit.increment();
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
        pipe
          ..transform(cubit)
          ..ngOnDestroy();
        cubit.increment();
        Timer.run(expectAsync0(() {
          expect(pipe.transform(cubit), 1);
        }));
      });
    });
  });
  group('null', () {
    test('should return null when given null', () {
      var pipe = CubitPipe(null);
      expect(pipe.transform(null), isNull);
    });
  });
}
