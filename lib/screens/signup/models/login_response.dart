import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(defaultValue: true)
  final bool success;
  @JsonKey(defaultValue: '')
  final String token;
  final LoginUserModel? user;

  @JsonKey(ignore: true)
  bool isAgent = false;

  LoginResponse({
    required this.success,
    required this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final response = _$LoginResponseFromJson(json);
    response.isAgent = json['isagent'] == true || 
                       json['is_agent'] == true || 
                       (json['user'] != null && 
                        (json['user']['isagent'] == true || 
                         json['user']['is_agent'] == true));
    return response;
  }
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginUserModel {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;

  LoginUserModel({
    required this.id,
    required this.username,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: (json['username'] as String?) ?? (json['name'] as String?) ?? '',
    );
  }
  Map<String, dynamic> toJson() => _$LoginUserModelToJson(this);
}
