import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_analytics/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBloc', () {
    test('initial state is AppState', () {
      expect(
        AppBloc().state,
        const AppState(),
      );
    });

    blocTest<AppBloc, AppState>(
      'changes tab correctly',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(const AppTabPressed(AppTab.shopping))
        ..add(const AppTabPressed(AppTab.cart))
        ..add(const AppTabPressed(AppTab.offers)),
      expect: () => const [
        AppState(currentTab: AppTab.shopping),
        AppState(currentTab: AppTab.cart),
        AppState(),
      ],
    );
  });
}
