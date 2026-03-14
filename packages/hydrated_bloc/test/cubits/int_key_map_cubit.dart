import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

/// Simulates the pattern produced by json_serializable
/// with `@JsonValue(int)` enums used as map keys.
/// See: https://github.com/felangel/bloc/issues/3983
class IntKeyMapCubit extends HydratedCubit<Palette> {
  IntKeyMapCubit() : super(const Palette({}));

  void update(Palette palette) => emit(palette);

  @override
  Map<String, dynamic> toJson(Palette state) => state.toJson();

  @override
  Palette fromJson(Map<String, dynamic> json) => Palette.fromJson(json);
}

/// An enum whose serialized form uses int values,
/// similar to `@JsonValue(int)` from json_annotation.
@immutable
class Season {
  const Season._(this.index, this.name);

  static const spring = Season._(0, 'spring');
  static const summer = Season._(1, 'summer');
  static const autumn = Season._(2, 'autumn');
  static const winter = Season._(3, 'winter');

  static const values = [spring, summer, autumn, winter];

  final int index;
  final String name;

  int toJson() => index;

  static Season fromJson(int value) =>
      values.firstWhere((e) => e.index == value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Season && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'Season.$name';
}

@immutable
class Palette {
  const Palette(this.seasonColors);

  factory Palette.fromJson(Map<String, dynamic> json) {
    final raw = json['seasonColors'] as Map<String, dynamic>? ?? {};
    return Palette(
      raw.map(
        (key, value) => MapEntry(
          Season.fromJson(int.parse(key)),
          value as String,
        ),
      ),
    );
  }

  final Map<Season, String> seasonColors;

  /// Produces a map with int keys (Season.index), matching the
  /// json_serializable output for `@JsonValue(int)` enums.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'seasonColors': seasonColors.map<int, String>(
        (key, value) => MapEntry(key.toJson(), value),
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Palette) return false;
    if (seasonColors.length != other.seasonColors.length) return false;
    for (final entry in seasonColors.entries) {
      if (other.seasonColors[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => seasonColors.hashCode;
}
