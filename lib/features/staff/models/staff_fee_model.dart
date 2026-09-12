class StaffFeeModel {
  final String? id;
  final String staffId;
  final String staffName;
  final String companyName;
  final double dailyRate;
  final int workDays;
  final double totalFee;
  final String paymentStatus; // 'Ödendi', 'Bekliyor'
  final String? paymentDate;

  StaffFeeModel({
    this.id,
    required this.staffId,
    required this.staffName,
    required this.companyName,
    required this.dailyRate,
    required this.workDays,
    required this.totalFee,
    required this.paymentStatus,
    this.paymentDate,
  });

  factory StaffFeeModel.fromJson(Map<String, dynamic> json) {
    return StaffFeeModel(
      id: json['id']?.toString(),
      staffId: json['staff_id']?.toString() ?? '',
      staffName: json['staff_name'] ?? '',
      companyName: json['company_name'] ?? '',
      dailyRate: (json['daily_rate'] as num?)?.toDouble() ?? 0.0,
      workDays: (json['work_days'] as num?)?.toInt() ?? 0,
      totalFee: (json['total_fee'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'Bekliyor',
      paymentDate: json['payment_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'staff_id': staffId,
      'staff_name': staffName,
      'company_name': companyName,
      'daily_rate': dailyRate,
      'work_days': workDays,
      'total_fee': totalFee,
      'payment_status': paymentStatus,
      if (paymentDate != null) 'payment_date': paymentDate,
    };
  }
}