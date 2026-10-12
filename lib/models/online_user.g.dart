// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OnlineUser _$OnlineUserFromJson(Map<String, dynamic> json) => OnlineUser(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
);

Map<String, dynamic> _$OnlineUserToJson(OnlineUser instance) =>
    <String, dynamic>{'id': instance.id, 'username': instance.username};
