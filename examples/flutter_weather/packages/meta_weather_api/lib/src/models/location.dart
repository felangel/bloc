import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

enum LocationType {
  @JsonValue('City')
  city,
  @JsonValue('Region')
  region,
  @JsonValue('State')
  state,
  @JsonValue('Province')
  province,
  @JsonValue('Country')
  country,
  @JsonValue('Continent')
  continent
}

@JsonSerializable()
class Location {
  const Location({
    required this.title,
    required this.locationType,
    required this.latLng,
    required this.woeid,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  final String title;
  final LocationType locationType;
  @JsonKey(name: 'latt_long')
  final LatLng latLng;
  final int woeid;
}

class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  factory LatLng.fromJson(String? json) {
    assert(json != null);
    final parts = json!.split(',');
    assert(parts.length == 2);
    return LatLng(
      latitude: double.tryParse(parts[0]) ?? 0,
      longitude: double.tryParse(parts[1]) ?? 0,
    );
  }

  final double latitude;
  final double longitude;
}
