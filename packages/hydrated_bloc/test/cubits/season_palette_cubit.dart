import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

/// A cubit that has a state which uses int key values in its serialized form.
/// https://github.com/felangel/bloc/issues/3983
class SeasonPaletteCubit extends HydratedCubit<SeasonPalette> {
  SeasonPaletteCubit() : super(const SeasonPalette({}));

  void update(SeasonPalette palette) => emit(palette);

  @override
  Map<String, dynamic> toJson(SeasonPalette state) => state.toJson();

  @override
  SeasonPalette fromJson(Map<String, dynamic> json) {
    return SeasonPalette.fromJson(json);
  }
}

@immutable
class SeasonPalette {
  const SeasonPalette(this.colors);

  factory SeasonPalette.fromJson(Map<String, dynamic> json) {
    final raw = json['colors'] as Map<String, dynamic>? ?? {};
    return SeasonPalette(
      raw.map(
        (key, value) => MapEntry(
          Season.fromJson(int.parse(key)),
          value as String,
        ),
      ),
    );
  }

  final Map<Season, String> colors;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'colors': colors.map<int, String>(
        (key, value) => MapEntry(key.toJson(), value),
      ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SeasonPalette) return false;
    if (colors.length != other.colors.length) return false;
    for (final entry in colors.entries) {
      if (other.colors[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => colors.hashCode;
}

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

  static Season fromJson(int value) {
    return values.firstWhere((e) => e.index == value);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Season && other.index == index;
  }

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'Season.$name';
}
