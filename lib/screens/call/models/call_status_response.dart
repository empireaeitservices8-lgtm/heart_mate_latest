class CallStatusResponse {
  final String message;
  final String? token;
  final String? channelName;
  final int? uid;

  CallStatusResponse({
    required this.message,
    this.token,
    this.channelName,
    this.uid,
  });

  factory CallStatusResponse.fromJson(Map<String, dynamic> json) {
    return CallStatusResponse(
      message: json['message'] as String? ?? '',
      token: json['token'] as String?,
      channelName: json['channel_name'] as String?,
      uid: (json['uid'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'channel_name': channelName,
      'uid': uid,
    };
  }
}
