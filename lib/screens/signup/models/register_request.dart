import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String password;
  final RegisterProfile profile;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.profile,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class RegisterProfile {
  final String name;
  final int age;
  final String gender;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String bio;

  RegisterProfile({
    required this.name,
    required this.age,
    required String gender,
    required this.phoneNumber,
    required this.bio,
  }) : gender = gender.toLowerCase();

  factory RegisterProfile.fromJson(Map<String, dynamic> json) => _$RegisterProfileFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterProfileToJson(this);
}
