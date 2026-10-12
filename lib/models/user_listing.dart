import 'package:json_annotation/json_annotation.dart';

part 'user_listing.g.dart';

@JsonSerializable()
class UserListing {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? username;
  @JsonKey(defaultValue: '')
  final String status;
  @JsonKey(defaultValue: false)
  final bool isVerified;
  final String? email;
  final String? phoneNumber;
  final bool isOnline;
  final bool isOnCall;
  final int coins;
  final Map<String, dynamic>? profile;

  UserListing({
    required this.id,
    required this.name,
    this.username,
    required this.status,
    required this.isVerified,
    this.email,
    this.phoneNumber,
    this.isOnline = false,
    this.isOnCall = false,
    this.coins = 0,
    this.profile,
  });

  factory UserListing.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;
    final nameVal = profile != null ? (profile['name'] as String? ?? '') : '';
    final isVerifiedVal = profile != null ? (profile['is_verified'] as bool? ?? false) : false;
    final usernameVal = json['username'] as String? ?? (profile != null ? profile['username'] as String? : null);
    
    final isOnline = json['is_online'] as bool? ?? (json['status'] == 'online');
    final isOnCall = json['is_on_call'] as bool? ?? (json['status'] == 'on call' || json['status'] == 'on_call');
    final statusVal = isOnCall ? 'on call' : (isOnline ? 'online' : 'offline');

    return UserListing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: nameVal.isNotEmpty ? nameVal : (usernameVal ?? json['name'] as String? ?? ''),
      username: usernameVal,
      status: statusVal,
      isVerified: isVerifiedVal,
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      isOnline: isOnline,
      isOnCall: isOnCall,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      profile: profile,
    );
  }
  Map<String, dynamic> toJson() => _$UserListingToJson(this);
}
