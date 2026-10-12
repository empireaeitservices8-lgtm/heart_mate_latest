import 'package:json_annotation/json_annotation.dart';

part 'online_user.g.dart';

@JsonSerializable()
class OnlineUser {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;

  OnlineUser({
    required this.id,
    required this.username,
  });

  factory OnlineUser.fromJson(Map<String, dynamic> json) => _$OnlineUserFromJson(json);
  Map<String, dynamic> toJson() => _$OnlineUserToJson(this);
}
