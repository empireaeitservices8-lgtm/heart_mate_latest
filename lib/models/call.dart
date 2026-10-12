import 'user_listing.dart';

enum CallType { voice, video }
enum CallRole { caller, callee }

enum CallStatus {
  idle,
  outgoing,
  ringing,
  incoming,
  accepting,
  connected,
  cancelled,
  rejected,
  missed,
  ended,
  remoteLeft
}

class CallSession {
  final int? callId;
  final String channelId;
  final UserListing contact;
  final CallType type;
  final CallRole role;
  final DateTime startTime;

  CallSession({
    this.callId,
    required this.channelId,
    required this.contact,
    required this.type,
    required this.role,
    required this.startTime,
  });
}

class CallLog {
  final String id;
  final String contactName;
  final String contactAvatar; 
  final int contactId;
  final DateTime timestamp;
  final int durationSeconds;
  final CallType type;
  final bool isIncoming;
  final bool wasConnected;
  final int coinsSpent;

  CallLog({
    required this.id,
    required this.contactName,
    required this.contactAvatar,
    required this.contactId,
    required this.timestamp,
    required this.durationSeconds,
    required this.type,
    required this.isIncoming,
    required this.wasConnected,
    required this.coinsSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'contactAvatar': contactAvatar,
      'contactId': contactId,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
      'type': type.index,
      'isIncoming': isIncoming,
      'wasConnected': wasConnected,
      'coinsSpent': coinsSpent,
    };
  }

  factory CallLog.fromJson(Map<String, dynamic> json) {
    return CallLog(
      id: json['id'] as String? ?? '',
      contactName: json['contactName'] as String? ?? '',
      contactAvatar: json['contactAvatar'] as String? ?? '',
      contactId: json['contactId'] as int? ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      type: CallType.values[json['type'] as int? ?? 0],
      isIncoming: json['isIncoming'] as bool? ?? false,
      wasConnected: json['wasConnected'] as bool? ?? false,
      coinsSpent: json['coinsSpent'] as int? ?? 0,
    );
  }
}
