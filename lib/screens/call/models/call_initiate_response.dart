import 'package:json_annotation/json_annotation.dart';

part 'call_initiate_response.g.dart';

@JsonSerializable()
class CallInitiateResponse {
  @JsonKey(name: 'call_id')
  final int callId;
  @JsonKey(name: 'channel_name')
  final String channelName;
  final String token;
  final int uid;

  CallInitiateResponse({
    required this.callId,
    required this.channelName,
    required this.token,
    required this.uid,
  });

  factory CallInitiateResponse.fromJson(Map<String, dynamic> json) => _$CallInitiateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CallInitiateResponseToJson(this);
}
