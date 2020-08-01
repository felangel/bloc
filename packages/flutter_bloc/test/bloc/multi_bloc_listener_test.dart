import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

void main() {
  group('MultiBlocListener', () {
    test(
      'throws if initialized with no listeners and no child',
      () {
        expect(
          () => MultiBlocListener(
            listeners: null,
            child: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'throws if initialized with no listeners',
      () {
        expect(
          () => MultiBlocListener(
            listeners: null,
            child: const SizedBox(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'throws if initialized with no child',
      () {
        expect(
          () => MultiBlocListener(
            listeners: [],
            child: null,
          ),
          throwsAssertionError,
        );
      },
    );

    test('is a MultiCubitListener internally', () {
      expect(
        MultiBlocListener(
          listeners: [
            BlocListener<CounterBloc, int>(
              listener: (_, __) {},
            ),
          ],
          child: const SizedBox(),
        ),
        isA<MultiCubitListener>(),
      );
    });
  });
}
