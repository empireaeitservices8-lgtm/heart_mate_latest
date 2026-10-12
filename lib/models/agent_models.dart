import 'user_listing.dart';

class AgentModel {
  final int id;
  final String username;
  final String email;
  final String? phoneNumber;
  final bool isOnline;
  final bool isOnCall;
  final int coins;
  final Map<String, dynamic>? profile;

  AgentModel({
    required this.id,
    required this.username,
    this.email = '',
    this.phoneNumber,
    this.isOnline = false,
    this.isOnCall = false,
    this.coins = 0,
    this.profile,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      isOnCall: json['is_on_call'] as bool? ?? false,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      profile: json['profile'] is Map<String, dynamic>
          ? json['profile'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'is_online': isOnline,
      'is_on_call': isOnCall,
      'coins': coins,
      'profile': profile,
    };
  }

  String get displayName {
    if (profile != null) {
      final pName = profile!['name'] as String?;
      if (pName != null && pName.trim().isNotEmpty) {
        return pName.trim();
      }
    }
    if (username.trim().isNotEmpty) {
      return username.trim();
    }
    return 'Agent #$id';
  }

  UserListing toUserListing() {
    final isVerifiedVal =
        profile != null ? (profile!['is_verified'] as bool? ?? false) : false;
    final statusVal = isOnCall ? 'on call' : (isOnline ? 'online' : 'offline');

    return UserListing(
      id: id,
      name: displayName,
      username: username,
      status: statusVal,
      isVerified: isVerifiedVal,
      email: email,
      phoneNumber: phoneNumber,
      isOnline: isOnline,
      isOnCall: isOnCall,
      coins: coins,
      profile: profile,
    );
  }
}
