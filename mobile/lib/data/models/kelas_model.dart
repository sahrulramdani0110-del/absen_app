class KelasModel {
  final int id;
  final int orgId;
  final String name;
  final String? description;
  final String? orgName;

  KelasModel({
    required this.id,
    required this.orgId,
    required this.name,
    this.description,
    this.orgName,
  });

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    return KelasModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      orgId: json['org_id'] is int ? json['org_id'] : int.tryParse(json['org_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      orgName: json['org_name'],
    );
  }
}
