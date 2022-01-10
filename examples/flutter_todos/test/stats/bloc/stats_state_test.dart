// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/stats/stats.dart';

void main() {
  group('StatsState', () {
    StatsState createSubject({
      StatsStatus status = StatsStatus.initial,
      int completedTodos = 0,
      int activeTodos = 0,
    }) {
      return StatsState(
        status: status,
        completedTodos: completedTodos,
        activeTodos: activeTodos,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject(
          status: StatsStatus.initial,
          completedTodos: 1,
          activeTodos: 2,
        ).props,
        equals(<Object?>[
          StatsStatus.initial, // status
          1, // completedTodos
          2, // activeTodos
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            status: null,
            completedTodos: null,
            activeTodos: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: StatsStatus.success,
            completedTodos: 1,
            activeTodos: 2,
          ),
          equals(
            createSubject(
              status: StatsStatus.success,
              completedTodos: 1,
              activeTodos: 2,
            ),
          ),
        );
      });
    });
  });
}
