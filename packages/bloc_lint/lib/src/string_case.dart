import 'package:collection/collection.dart';

/// Extension on [String] that add support for converting
/// to snake_case.
extension SnakeCaseX on String {
  /// Returns the snake_case equivalent of the current string.
  String toSnakeCase() {
    return split('').mapIndexed((index, character) {
      if (index == 0) return character.toLowerCase();
      if (character.toUpperCase() == character) {
        return '_${character.toLowerCase()}';
      }
      return character;
    }).join();
  }
}
