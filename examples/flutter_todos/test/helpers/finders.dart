import 'package:flutter_test/flutter_test.dart';

extension ExtraFinders on CommonFinders {
  /// Finds a widget by a specific type [T].
  ///
  /// ```dart
  /// find.bySpecificType<Foo<Bar>>()
  /// ```
  Finder bySpecificType<T>() => find.byType(T);
}
