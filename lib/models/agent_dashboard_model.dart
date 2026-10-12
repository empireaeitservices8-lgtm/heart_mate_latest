class AgentDashboardModel {
  final String status;
  final AgentInfo agent;
  final AgentTasks tasks;

  AgentDashboardModel({
    required this.status,
    required this.agent,
    required this.tasks,
  });

  factory AgentDashboardModel.fromJson(Map<String, dynamic> json) {
    final agentMap = json['agent'] is Map
        ? Map<String, dynamic>.from(json['agent'] as Map)
        : (json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{});
    final tasksMap = json['tasks'] is Map
        ? Map<String, dynamic>.from(json['tasks'] as Map)
        : <String, dynamic>{};

    return AgentDashboardModel(
      status: json['status']?.toString() ?? 'success',
      agent: AgentInfo.fromJson(agentMap),
      tasks: AgentTasks.fromJson(tasksMap),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'agent': agent.toJson(),
        'tasks': tasks.toJson(),
      };
}

class AgentInfo {
  final String username;
  final int coinsEarned;
  final int walletBalance;
  final num totalEarnings;
  final num todayEarnings;
  final int totalDurationSeconds;
  final int todayDurationSeconds;
  final String totalDurationFormatted;
  final String todayDurationFormatted;
  final int callsCompleted;
  final num successRate;
  final double agentRating;

  AgentInfo({
    required this.username,
    required this.coinsEarned,
    required this.walletBalance,
    required this.totalEarnings,
    required this.todayEarnings,
    required this.totalDurationSeconds,
    required this.todayDurationSeconds,
    required this.totalDurationFormatted,
    required this.todayDurationFormatted,
    required this.callsCompleted,
    required this.successRate,
    required this.agentRating,
  });

  factory AgentInfo.fromJson(Map<String, dynamic> json) {
    return AgentInfo(
      username: json['username']?.toString() ?? '',
      coinsEarned: (json['coins_earned'] as num?)?.toInt() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['total_earnings'] as num?) ?? (json['coins'] as num?) ?? 0,
      todayEarnings: (json['today_earnings'] as num?) ?? 0,
      totalDurationSeconds: (json['total_duration_seconds'] as num?)?.toInt() ?? 0,
      todayDurationSeconds: (json['today_duration_seconds'] as num?)?.toInt() ?? 0,
      totalDurationFormatted: json['total_duration_formatted']?.toString() ??
          json['talk_duration']?.toString() ??
          '0h 0m',
      todayDurationFormatted: json['today_duration_formatted']?.toString() ?? '0h 0m',
      callsCompleted: (json['calls_completed'] as num?)?.toInt() ?? 0,
      successRate: (json['success_rate'] as num?) ?? 100,
      agentRating: (json['agent_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          4.9,
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'coins_earned': coinsEarned,
        'wallet_balance': walletBalance,
        'total_earnings': totalEarnings,
        'today_earnings': todayEarnings,
        'total_duration_seconds': totalDurationSeconds,
        'today_duration_seconds': todayDurationSeconds,
        'total_duration_formatted': totalDurationFormatted,
        'today_duration_formatted': todayDurationFormatted,
        'calls_completed': callsCompleted,
        'success_rate': successRate,
        'agent_rating': agentRating,
      };
}

class AgentTasks {
  final AgentTask daily;
  final AgentTask weekly;
  final AgentTask monthly;

  AgentTasks({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory AgentTasks.fromJson(Map<String, dynamic> json) {
    return AgentTasks(
      daily: AgentTask.fromJson(
        json['daily'] is Map ? Map<String, dynamic>.from(json['daily'] as Map) : {},
        defaultTarget: 50,
      ),
      weekly: AgentTask.fromJson(
        json['weekly'] is Map ? Map<String, dynamic>.from(json['weekly'] as Map) : {},
        defaultTarget: 250,
      ),
      monthly: AgentTask.fromJson(
        json['monthly'] is Map ? Map<String, dynamic>.from(json['monthly'] as Map) : {},
        defaultTarget: 1000,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'daily': daily.toJson(),
        'weekly': weekly.toJson(),
        'monthly': monthly.toJson(),
      };
}

class AgentTask {
  final int completed;
  final int target;
  final num progressPercentage;

  AgentTask({
    required this.completed,
    required this.target,
    required this.progressPercentage,
  });

  factory AgentTask.fromJson(Map<String, dynamic> json, {int defaultTarget = 0}) {
    final completedVal = (json['completed'] as num?)?.toInt() ?? 0;
    final targetVal = (json['target'] as num?)?.toInt() ?? defaultTarget;
    final progress = (json['progress_percentage'] as num?) ??
        (targetVal > 0 ? ((completedVal / targetVal) * 100).clamp(0, 100) : 0);

    return AgentTask(
      completed: completedVal,
      target: targetVal,
      progressPercentage: progress,
    );
  }

  Map<String, dynamic> toJson() => {
        'completed': completed,
        'target': target,
        'progress_percentage': progressPercentage,
      };
}
