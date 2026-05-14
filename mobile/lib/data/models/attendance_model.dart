class AttendanceModel {
  final int id;
  final int sessionId;
  final int userId;
  final DateTime checkedInAt;
  final double? latitude;
  final double? longitude;
  final String? photoUrl;
  final String status;
  final String? deviceType;
  final String? sessionTitle;
  final String? kelasName;
  final String? userName;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.checkedInAt,
    this.latitude,
    this.longitude,
    this.photoUrl,
    required this.status,
    this.deviceType,
    this.sessionTitle,
    this.kelasName,
    this.userName,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sessionId: json['session_id'] is int ? json['session_id'] : int.tryParse(json['session_id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      checkedInAt: DateTime.parse(json['checked_in_at']),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      photoUrl: json['photo_url'],
      status: json['status'] ?? 'hadir',
      deviceType: json['device_type'],
      sessionTitle: json['title'],
      kelasName: json['kelas_name'],
      userName: json['name'],
    );
  }
}
