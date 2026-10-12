// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_initiate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallInitiateResponse _$CallInitiateResponseFromJson(
        Map<String, dynamic> json) =>
    CallInitiateResponse(
      callId: (json['call_id'] as num).toInt(),
      channelName: json['channel_name'] as String,
      token: json['token'] as String,
      uid: (json['uid'] as num).toInt(),
    );

Map<String, dynamic> _$CallInitiateResponseToJson(
        CallInitiateResponse instance) =>
    <String, dynamic>{
      'call_id': instance.callId,
      'channel_name': instance.channelName,
      'token': instance.token,
      'uid': instance.uid,
    };
