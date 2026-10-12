// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'help_line.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HelpLine _$HelpLineFromJson(Map<String, dynamic> json) => HelpLine(
  phone: json['phone_number'] as String? ?? '',
  email: json['email'] as String? ?? '',
  available: json['available'] as String? ?? '',
  address: json['address'] as String? ?? '',
);

Map<String, dynamic> _$HelpLineToJson(HelpLine instance) => <String, dynamic>{
  'phone_number': instance.phone,
  'email': instance.email,
  'available': instance.available,
  'address': instance.address,
};
