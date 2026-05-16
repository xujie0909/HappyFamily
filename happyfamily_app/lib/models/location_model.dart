class LocationModel {
  final double latitude;
  final double longitude;
  final double speed;
  final double heading;
  final double accuracy;
  final String address;
  final DateTime updatedAt;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.speed = 0,
    this.heading = 0,
    this.accuracy = 0,
    this.address = '',
    required this.updatedAt,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: (json['speed'] as num?)?.toDouble() ?? 0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      address: json['address'] ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  String get speedText {
    final kmh = speed * 3.6;
    if (kmh < 1) return '静止';
    if (kmh < 5) return '步行';
    if (kmh < 20) return '骑行';
    return '${kmh.toStringAsFixed(0)} km/h';
  }
}
