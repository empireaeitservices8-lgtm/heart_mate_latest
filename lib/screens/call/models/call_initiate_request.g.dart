// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_initiate_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallInitiateRequest _$CallInitiateRequestFromJson(Map<String, dynamic> json) =>
    CallInitiateRequest(
      receiverId: (json['receiver_id'] as num).toInt(),
    );

Map<String, dynamic> _$CallInitiateRequestToJson(
        CallInitiateRequest instance) =>
    <String, dynamic>{
      'receiver_id': instance.receiverId,
    };
