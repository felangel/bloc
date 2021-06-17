```dart
enum LocationType {
  city,
  region,
  state,
  province,
  country,
  continent
}

class Location {
  const Location({
    required this.title,
    required this.locationType,
    required this.latLng,
    required this.woeid,
  });

  final String title;
  final LocationType locationType;
  final LatLng latLng;
  final int woeid;
}

class LatLng {
  const LatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
```