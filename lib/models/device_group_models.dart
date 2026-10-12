class DeviceGroupModel {
  final int id;
  final String name;
  final String description;
  final int deviceCount;
  final String createdAt;

  const DeviceGroupModel({
    required this.id,
    required this.name,
    this.description = '',
    this.deviceCount = 0,
    this.createdAt = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'device_count': deviceCount,
        'created_at': createdAt,
      };

  factory DeviceGroupModel.fromJson(Map<String, dynamic> json) {
    return DeviceGroupModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Group',
      description: json['description']?.toString() ?? '',
      deviceCount: json['device_count'] as int? ?? (json['devices'] is List ? (json['devices'] as List).length : 0),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class AddDeviceGroupRequest {
  final String name;
  final String description;

  const AddDeviceGroupRequest({
    required this.name,
    this.description = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };

  factory AddDeviceGroupRequest.fromJson(Map<String, dynamic> json) => AddDeviceGroupRequest(
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );
}

class AddDeviceToGroupRequest {
  final int groupId;
  final int deviceId;

  const AddDeviceToGroupRequest({
    required this.groupId,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'device_id': deviceId,
      };

  factory AddDeviceToGroupRequest.fromJson(Map<String, dynamic> json) => AddDeviceToGroupRequest(
        groupId: json['group_id'] as int? ?? 0,
        deviceId: json['device_id'] as int? ?? 0,
      );
}
