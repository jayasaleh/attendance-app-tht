import 'dart:convert';

class AttendanceRecord {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final bool withinRadius;
  final String imagePath;
  final String? address;

  AttendanceRecord({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.withinRadius,
    required this.imagePath,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'withinRadius': withinRadius,
    'imagePath': imagePath,
    'address': address,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      withinRadius: json['withinRadius'] as bool,
      imagePath: json['imagePath'] as String,
      address: json['address'] as String?,
    );
  }

  static List<AttendanceRecord> listFromJsonString(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> raw = json.decode(jsonStr) as List<dynamic>;
    return raw
        .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJsonString(List<AttendanceRecord> items) {
    final raw = items.map((e) => e.toJson()).toList();
    return json.encode(raw);
  }
}
