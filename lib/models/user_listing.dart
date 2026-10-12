import 'package:json_annotation/json_annotation.dart';

part 'user_listing.g.dart';

@JsonSerializable()
class UserListing {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String status;
  @JsonKey(defaultValue: false)
  final bool isVerified;

  UserListing({
    required this.id,
    required this.name,
    required this.status,
    required this.isVerified,
  });

  factory UserListing.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    final nameVal = profile != null ? (profile['name'] as String? ?? '') : '';
    final isVerifiedVal = profile != null ? (profile['is_verified'] as bool? ?? false) : false;
    
    final isOnline = json['is_online'] as bool? ?? false;
    final statusVal = isOnline ? 'online' : 'offline';

    return UserListing(
      id: json['id'] as int? ?? 0,
      name: nameVal.isNotEmpty ? nameVal : (json['username'] as String? ?? ''),
      status: statusVal,
      isVerified: isVerifiedVal,
    );
  }
  Map<String, dynamic> toJson() => _$UserListingToJson(this);
}
