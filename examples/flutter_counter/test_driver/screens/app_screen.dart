import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

class AppScreen {
  AppScreen(FlutterDriver flutterDriver) {
    _driver = flutterDriver;
  }

  final incrementFloatingButton =
      find.byValueKey('counterView_increment_floatingActionButton');
  final decrementFloatingButton =
      find.byValueKey('counterView_decrement_floatingActionButton');
  final appBarText = find.text('Counter');
  final counterState = find.byValueKey('counterState');
  FlutterDriver _driver;

  /// verify the AppBar text is Counter
  Future<void> verifyTheAppBarText() async {
    expect(await _getTextByScreen(appBarText), 'Counter');
  }

  Future<void> verifyCounterTextIsZero() async {
    expect(await _getTextByScreen(counterState), '0');
  }

  Future<void> pressIncrementFloatingActionButtonTwice() async {
    // tap floating action button
    await _driver.tap(incrementFloatingButton);
    expect(await _getTextByScreen(counterState), '1');

    // tap floating action button
    await _driver.tap(incrementFloatingButton);
    expect(await _getTextByScreen(counterState), '2');
  }

  Future<void> decrementFloatingActionButton() async {
    await _driver.tap(decrementFloatingButton);
    expect(await _getTextByScreen(counterState), '1');
  }

  Future<String> _getTextByScreen(SerializableFinder finder) async {
    return await _driver.getText(finder);
  }
}
