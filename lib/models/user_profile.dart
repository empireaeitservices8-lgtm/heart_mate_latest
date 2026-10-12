import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(defaultValue: '')
  final String email;
  @JsonKey(name: 'is_online', defaultValue: false)
  final bool isOnline;
  @JsonKey(name: 'profile')
  final ProfileDetails? rawProfile;
  @JsonKey(name: 'isagent', defaultValue: false)
  final bool isAgent;

  ProfileDetails get profile => rawProfile ?? const ProfileDetails(name: '', age: 0, gender: '', phoneNumber: '', bio: '');

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.isOnline,
    this.rawProfile,
    this.isAgent = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    String parsedUsername = '';
    String parsedEmail = '';
    bool parsedIsOnline = false;
    ProfileDetails? parsedProfile;

    if (json.containsKey('user') && json['user'] is Map) {
      final userMap = json['user'] as Map<String, dynamic>;
      parsedUsername = userMap['username'] as String? ?? '';
      parsedEmail = userMap['email'] as String? ?? '';
      parsedIsOnline = userMap['is_online'] as bool? ?? false;
    } else {
      parsedUsername = json['username'] as String? ?? '';
      parsedEmail = json['email'] as String? ?? '';
      parsedIsOnline = json['is_online'] as bool? ?? false;
    }

    if (json.containsKey('profile') && json['profile'] is Map) {
      parsedProfile = ProfileDetails.fromJson(json['profile'] as Map<String, dynamic>);
    } else {
      parsedProfile = ProfileDetails(
        name: json['name'] as String? ?? '',
        age: (json['age'] as num?)?.toInt() ?? 0,
        gender: json['gender'] as String? ?? '',
        phoneNumber: json['phone_number'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
      );
    }

    final bool parsedIsAgent = json['isagent'] == true || 
                               json['is_agent'] == true || 
                               (json['user'] != null && 
                                (json['user']['isagent'] == true || 
                                 json['user']['is_agent'] == true));

    return UserProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: parsedUsername,
      email: parsedEmail,
      isOnline: parsedIsOnline,
      rawProfile: parsedProfile,
      isAgent: parsedIsAgent,
    );
  }

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class ProfileDetails {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 0)
  final int age;
  @JsonKey(defaultValue: '')
  final String gender;
  @JsonKey(name: 'phone_number', defaultValue: '')
  final String phoneNumber;
  @JsonKey(defaultValue: '')
  final String bio;

  const ProfileDetails({
    required this.name,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.bio,
  });

  factory ProfileDetails.fromJson(Map<String, dynamic> json) => _$ProfileDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDetailsToJson(this);
}
