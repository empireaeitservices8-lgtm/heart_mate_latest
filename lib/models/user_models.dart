class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final int devicesCount;
  final int groupsCount;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.role = 'Member',
    this.status = 'active',
    this.devicesCount = 0,
    this.groupsCount = 0,
    this.createdAt = '',
  });

  bool get isActive => status.toLowerCase() == 'active';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'devices_count': devicesCount,
        'groups_count': groupsCount,
        'created_at': createdAt,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? json['username']?.toString() ?? 'Unnamed User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Member',
      status: json['status']?.toString() ?? 'active',
      devicesCount: json['devices_count'] as int? ?? 0,
      groupsCount: json['groups_count'] as int? ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class AddUserRequest {
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? password;

  const AddUserRequest({
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'Member',
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        if (password != null) 'password': password,
      };

  factory AddUserRequest.fromJson(Map<String, dynamic> json) => AddUserRequest(
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? 'Member',
      );
}
