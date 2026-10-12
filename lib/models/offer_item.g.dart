// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OfferItem _$OfferItemFromJson(Map<String, dynamic> json) => OfferItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  coins: (json['coins'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OfferItemToJson(OfferItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'coins': instance.coins,
};
