class SessionModel {
  final int id;
  final int kelasId;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;
  final String status;
  final String? kelasName;
  final String? createdByName;

  SessionModel({
    required this.id,
    required this.kelasId,
    required this.title,
    required this.startTime,
    this.endTime,
    this.latitude,
    this.longitude,
    this.radiusMeters = 100,
    required this.status,
    this.kelasName,
    this.createdByName,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      kelasId: json['kelas_id'] is int ? json['kelas_id'] : int.tryParse(json['kelas_id'].toString()) ?? 0,
      title: json['title'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      radiusMeters: json['radius_meters'] != null ? double.tryParse(json['radius_meters'].toString()) ?? 100 : 100,
      status: json['status'] ?? 'open',
      kelasName: json['kelas_name'],
      createdByName: json['created_by_name'],
    );
  }

  bool get isOpen => status == 'open';
  bool get hasLocation => latitude != null && longitude != null;
}
