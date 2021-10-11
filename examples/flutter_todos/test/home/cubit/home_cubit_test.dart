import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todos/home/home.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HomeCubit', () {
    setUpAll(commonSetUpAll);

    HomeCubit buildCubit() => HomeCubit();

    group('constructor', () {
      test('works properly', () {
        expect(buildCubit, returnsNormally);
      });

      test('has correct initial state', () {
        expect(
          buildCubit().state,
          equals(const HomeState()),
        );
      });
    });

    group('setTab', () {
      blocTest<HomeCubit, HomeState>(
        'sets tab to given value',
        build: buildCubit,
        act: (cubit) => cubit.setTab(HomeTab.stats),
        expect: () => [
          const HomeState(tab: HomeTab.stats),
        ],
      );
    });
  });
}
