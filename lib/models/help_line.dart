import 'package:json_annotation/json_annotation.dart';

part 'help_line.g.dart';

@JsonSerializable()
class HelpLine {
  @JsonKey(name: 'phone_number', defaultValue: '')
  final String phone;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(defaultValue: '')
  final String available;
  @JsonKey(defaultValue: '')
  final String address;

  HelpLine({
    required this.phone,
    required this.email,
    required this.available,
    required this.address,
  });

  factory HelpLine.fromJson(Map<String, dynamic> json) => _$HelpLineFromJson(json);
  Map<String, dynamic> toJson() => _$HelpLineToJson(this);
}
