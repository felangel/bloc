import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

class AppScreen {
  const AppScreen(this._driver);

  static final incrementFloatingButton =
      find.byValueKey('counterView_increment_floatingActionButton');
  static final decrementFloatingButton =
      find.byValueKey('counterView_decrement_floatingActionButton');
  static final appBarText = find.text('Counter');
  static final counterState = find.byValueKey('counterState');
  final FlutterDriver _driver;

  /// verify the AppBar text is Counter
  Future<void> verifyTheAppBarText() async {
    expect(await _driver.getText(appBarText), 'Counter');
  }

  Future<void> verifyCounterTextIsZero() async {
    expect(await _driver.getText(counterState), '0');
  }

  Future<void> pressIncrementFloatingActionButtonTwice() async {
    // tap floating action button
    await _driver.tap(incrementFloatingButton);
    expect(await _driver.getText(counterState), '1');

    // tap floating action button
    await _driver.tap(incrementFloatingButton);
    expect(await _driver.getText(counterState), '2');
  }

  Future<void> decrementFloatingActionButton() async {
    await _driver.tap(decrementFloatingButton);
    expect(await _driver.getText(counterState), '1');
  }
}
