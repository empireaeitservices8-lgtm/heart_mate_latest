class DeviceUserCountModel {
  final int totalDevices;
  final int activeDevices;
  final int totalUsers;
  final int activeUsers;
  final int totalGroups;

  const DeviceUserCountModel({
    required this.totalDevices,
    required this.activeDevices,
    required this.totalUsers,
    required this.activeUsers,
    this.totalGroups = 0,
  });

  Map<String, dynamic> toJson() => {
        'total_devices': totalDevices,
        'active_devices': activeDevices,
        'total_users': totalUsers,
        'active_users': activeUsers,
        'total_groups': totalGroups,
      };

  factory DeviceUserCountModel.fromJson(Map<String, dynamic> json) {
    return DeviceUserCountModel(
      totalDevices: json['total_devices'] as int? ?? 0,
      activeDevices: json['active_devices'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalGroups: json['total_groups'] as int? ?? 0,
    );
  }
}

class LicenseSummaryModel {
  final int totalLicenses;
  final int usedLicenses;
  final String expiryDate;
  final String licenseType;
  final String status;

  const LicenseSummaryModel({
    required this.totalLicenses,
    required this.usedLicenses,
    required this.expiryDate,
    this.licenseType = 'Enterprise',
    this.status = 'active',
  });

  int get availableLicenses => (totalLicenses - usedLicenses).clamp(0, totalLicenses);
  double get utilizationPercentage =>
      totalLicenses > 0 ? (usedLicenses / totalLicenses).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'total_licenses': totalLicenses,
        'used_licenses': usedLicenses,
        'expiry_date': expiryDate,
        'license_type': licenseType,
        'status': status,
      };

  factory LicenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return LicenseSummaryModel(
      totalLicenses: json['total_licenses'] as int? ?? 100,
      usedLicenses: json['used_licenses'] as int? ?? 32,
      expiryDate: json['expiry_date']?.toString() ?? '2027-12-31',
      licenseType: json['license_type']?.toString() ?? 'Enterprise',
      status: json['status']?.toString() ?? 'active',
    );
  }
}
