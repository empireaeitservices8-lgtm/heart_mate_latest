class RequestOtpRequest {
  final String phoneOrEmail;

  const RequestOtpRequest({required this.phoneOrEmail});

  Map<String, dynamic> toJson() => {
        'phone_or_email': phoneOrEmail,
      };

  factory RequestOtpRequest.fromJson(Map<String, dynamic> json) =>
      RequestOtpRequest(phoneOrEmail: json['phone_or_email']?.toString() ?? '');
}

class VerifyOtpRequest {
  final String phoneOrEmail;
  final String otp;

  const VerifyOtpRequest({required this.phoneOrEmail, required this.otp});

  Map<String, dynamic> toJson() => {
        'phone_or_email': phoneOrEmail,
        'otp': otp,
      };

  factory VerifyOtpRequest.fromJson(Map<String, dynamic> json) =>
      VerifyOtpRequest(
        phoneOrEmail: json['phone_or_email']?.toString() ?? '',
        otp: json['otp']?.toString() ?? '',
      );
}

class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        username: json['username']?.toString() ?? '',
        password: json['password']?.toString() ?? '',
      );
}

class AuthUserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;

  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'user',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      };

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'] as int? ?? 0,
        name: json['name']?.toString() ?? json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? 'user',
      );
}

class AuthResponse {
  final String token;
  final String refreshToken;
  final AuthUserModel? user;
  final String? message;

  const AuthResponse({
    required this.token,
    this.refreshToken = '',
    this.user,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'refresh_token': refreshToken,
        'user': user?.toJson(),
        'message': message,
      };

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token']?.toString() ?? json['access']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? json['refresh']?.toString() ?? '',
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? AuthUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }
}
