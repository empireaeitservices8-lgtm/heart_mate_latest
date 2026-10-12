import 'package:json_annotation/json_annotation.dart';

part 'offer_item.g.dart';

@JsonSerializable()
class OfferItem {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: 0)
  final int coins;

  OfferItem({
    required this.id,
    required this.title,
    required this.coins,
  });

  factory OfferItem.fromJson(Map<String, dynamic> json) => _$OfferItemFromJson(json);
  Map<String, dynamic> toJson() => _$OfferItemToJson(this);
}
