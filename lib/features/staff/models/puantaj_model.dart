class PuantajModel {
  final String? id;
  final String staffId;
  final String workDate;
  final String role;
  final String city;
  final double dailyFee;
  final String? staffFullName;

  PuantajModel({
    this.id,
    required this.staffId,
    required this.workDate,
    required this.role,
    required this.city,
    required this.dailyFee,
    this.staffFullName,
  });

  factory PuantajModel.fromJson(Map<String, dynamic> json) {
    return PuantajModel(
      id: json['id']?.toString(),
      staffId: json['staff_id']?.toString() ?? '',
      workDate: json['work_date'] ?? '',
      role: json['role'] ?? 'Sayman',
      city: json['city'] ?? '',
      dailyFee: (json['daily_fee'] as num?)?.toDouble() ?? 0.0,
      staffFullName: json['staff'] != null ? json['staff']['full_name'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'staff_id': staffId,
      'work_date': workDate,
      'role': role,
      'city': city,
      'daily_fee': dailyFee,
    };
  }
}