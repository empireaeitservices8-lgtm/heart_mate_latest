// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      token: json['token'] as String? ?? '',
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'message': instance.message,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
  phoneNumber: json['phone_number'] as String? ?? '',
  isOnline: json['is_online'] as bool? ?? false,
  isOnCall: json['is_on_call'] as bool? ?? false,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String? ?? '',
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'is_online': instance.isOnline,
  'is_on_call': instance.isOnCall,
  'coins': instance.coins,
  'created_at': instance.createdAt,
};
