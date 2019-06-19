import 'package:flutter/widgets.dart';

/// A mixin on `Widget` which exposes a `copyWith` method.
mixin Copyable on Widget {
  /// `copyWith` takes a child `Widget` and must create a copy of itself with the new child.
  /// All values except child (including [Key]) should be preserved.
  Widget copyWith(Widget child);
}
