import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse {
  @JsonKey(defaultValue: '')
  final String token;
  final UserModel? user;
  @JsonKey(defaultValue: '')
  final String message;

  RegisterResponse({
    required this.token,
    this.user,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

@JsonSerializable()
class UserModel {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(name: 'phone_number', defaultValue: '')
  final String phoneNumber;
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;
  @JsonKey(name: 'is_on_call', defaultValue: false)
  final bool isOnCall;
  @JsonKey(defaultValue: 0)
  final int coins;
  @JsonKey(name: 'created_at', defaultValue: '')
  final String createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.isOnline,
    required this.isOnCall,
    required this.coins,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
