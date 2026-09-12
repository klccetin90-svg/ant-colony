class StaffModel {
  final String? id;
  final String fullName;
  final String tcNo;
  final String iban;
  final String ibanOwnerType;
  final String birthDate;
  final String city;
  final String phone;
  final String role;
  final String? createdAt; // <--- EKLENDİ

  StaffModel({
    this.id,
    required this.fullName,
    required this.tcNo,
    required this.iban,
    required this.ibanOwnerType,
    required this.birthDate,
    required this.city,
    required this.phone,
    required this.role,
    this.createdAt, // <--- EKLENDİ
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id']?.toString(),
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      tcNo: json['tc_no'] ?? json['tcNo'] ?? '',
      iban: json['iban'] ?? '',
      ibanOwnerType: json['iban_owner_type'] ?? json['ibanOwnerType'] ?? 'Kendisi',
      birthDate: json['birth_date'] ?? json['birthDate'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['created_at']?.toString(), // <--- EKLENDİ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      'tc_no': tcNo,
      'iban': iban,
      'iban_owner_type': ibanOwnerType,
      'birth_date': birthDate,
      'city': city,
      'phone': phone,
      'role': role,
      if (createdAt != null) 'created_at': createdAt, // <--- EKLENDİ
    };
  }
}