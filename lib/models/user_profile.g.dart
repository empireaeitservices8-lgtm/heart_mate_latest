// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
  isOnline: json['is_online'] as bool? ?? false,
  rawProfile: json['profile'] == null
      ? null
      : ProfileDetails.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'is_online': instance.isOnline,
      'profile': instance.rawProfile,
    };

ProfileDetails _$ProfileDetailsFromJson(Map<String, dynamic> json) =>
    ProfileDetails(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );

Map<String, dynamic> _$ProfileDetailsToJson(ProfileDetails instance) =>
    <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'phone_number': instance.phoneNumber,
      'bio': instance.bio,
    };
