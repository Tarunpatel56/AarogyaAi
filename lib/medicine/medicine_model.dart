class MedicineModel {
  final String medicineName;
  final String usageInfo;
  final String dosageInfo;
  final String warningInfo;

  MedicineModel({
    required this.medicineName,
    required this.usageInfo,
    required this.dosageInfo,
    required this.warningInfo,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      medicineName: map['medicine_name'] ?? '',
      usageInfo: map['usage_info'] ?? '',
      dosageInfo: map['dosage_info'] ?? '',
      warningInfo: map['warning_info'] ?? '',
    );
  }
}
