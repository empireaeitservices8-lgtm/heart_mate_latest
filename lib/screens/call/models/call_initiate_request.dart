import 'package:json_annotation/json_annotation.dart';

part 'call_initiate_request.g.dart';

@JsonSerializable()
class CallInitiateRequest {
  @JsonKey(name: 'receiver_id')
  final int receiverId;

  CallInitiateRequest({required this.receiverId});

  factory CallInitiateRequest.fromJson(Map<String, dynamic> json) => _$CallInitiateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CallInitiateRequestToJson(this);
}
