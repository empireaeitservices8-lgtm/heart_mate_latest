// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserListing _$UserListingFromJson(Map<String, dynamic> json) => UserListing(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  status: json['status'] as String? ?? '',
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$UserListingToJson(UserListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': instance.status,
      'isVerified': instance.isVerified,
    };
