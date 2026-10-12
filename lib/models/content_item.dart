import 'package:json_annotation/json_annotation.dart';

part 'content_item.g.dart';

@JsonSerializable()
class ContentItem {
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: '')
  final String content;

  ContentItem({
    required this.title,
    required this.content,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) => _$ContentItemFromJson(json);
  Map<String, dynamic> toJson() => _$ContentItemToJson(this);
}
