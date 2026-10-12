class DeviceModel {
  final int id;
  final String name;
  final String serialNumber;
  final String model;
  final String status;
  final int? deviceTypeId;
  final String? deviceTypeName;
  final int? assignedUserId;
  final String? assignedUserName;
  final int? groupId;
  final String? groupName;
  final String createdAt;

  const DeviceModel({
    required this.id,
    required this.name,
    required this.serialNumber,
    this.model = '',
    this.status = 'active',
    this.deviceTypeId,
    this.deviceTypeName,
    this.assignedUserId,
    this.assignedUserName,
    this.groupId,
    this.groupName,
    this.createdAt = '',
  });

  bool get isActive => status.toLowerCase() == 'active' || status.toLowerCase() == 'online';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serial_number': serialNumber,
        'model': model,
        'status': status,
        'device_type_id': deviceTypeId,
        'device_type_name': deviceTypeName,
        'assigned_user_id': assignedUserId,
        'assigned_user_name': assignedUserName,
        'group_id': groupId,
        'group_name': groupName,
        'created_at': createdAt,
      };

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Device',
      serialNumber: json['serial_number']?.toString() ?? json['imei']?.toString() ?? 'N/A',
      model: json['model']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      deviceTypeId: json['device_type_id'] as int?,
      deviceTypeName: json['device_type_name']?.toString(),
      assignedUserId: json['assigned_user_id'] as int?,
      assignedUserName: json['assigned_user_name']?.toString(),
      groupId: json['group_id'] as int?,
      groupName: json['group_name']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class DeviceTypeModel {
  final int id;
  final String name;
  final String code;
  final String icon;

  const DeviceTypeModel({
    required this.id,
    required this.name,
    required this.code,
    this.icon = 'devices',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'icon': icon,
      };

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) {
    return DeviceTypeModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'devices',
    );
  }
}

class AddDeviceRequest {
  final String name;
  final String serialNumber;
  final int deviceTypeId;
  final int? groupId;
  final int? assignedUserId;

  const AddDeviceRequest({
    required this.name,
    required this.serialNumber,
    required this.deviceTypeId,
    this.groupId,
    this.assignedUserId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'serial_number': serialNumber,
        'device_type_id': deviceTypeId,
        if (groupId != null) 'group_id': groupId,
        if (assignedUserId != null) 'assigned_user_id': assignedUserId,
      };

  factory AddDeviceRequest.fromJson(Map<String, dynamic> json) => AddDeviceRequest(
        name: json['name']?.toString() ?? '',
        serialNumber: json['serial_number']?.toString() ?? '',
        deviceTypeId: json['device_type_id'] as int? ?? 1,
        groupId: json['group_id'] as int?,
        assignedUserId: json['assigned_user_id'] as int?,
      );
}

class TransferKeyRequest {
  final int deviceId;
  final int toUserId;
  final String? note;

  const TransferKeyRequest({
    required this.deviceId,
    required this.toUserId,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'to_user_id': toUserId,
        if (note != null) 'note': note,
      };

  factory TransferKeyRequest.fromJson(Map<String, dynamic> json) => TransferKeyRequest(
        deviceId: json['device_id'] as int? ?? 0,
        toUserId: json['to_user_id'] as int? ?? 0,
        note: json['note']?.toString(),
      );
}
