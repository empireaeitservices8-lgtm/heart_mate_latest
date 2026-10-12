// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      password: json['password'] as String,
      profile: RegisterProfile.fromJson(
        json['profile'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'password': instance.password,
      'profile': instance.profile,
    };

RegisterProfile _$RegisterProfileFromJson(Map<String, dynamic> json) =>
    RegisterProfile(
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      phoneNumber: json['phone_number'] as String,
      bio: json['bio'] as String,
    );

Map<String, dynamic> _$RegisterProfileToJson(RegisterProfile instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'phone_number': instance.phoneNumber,
      'bio': instance.bio,
    };
