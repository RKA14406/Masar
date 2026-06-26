class Ada2kSummary {
  final Ada2kUser user;
  final Ada2kGoal goal;
  final Ada2kProgress progress;
  final Ada2kCohort cohort;
  final Ada2kStatus status;
  final List<Ada2kLeaderboardEntry> leaderboard;
  final Ada2kAnalysis analysis;

  Ada2kSummary({
    required this.user,
    required this.goal,
    required this.progress,
    required this.cohort,
    required this.status,
    required this.leaderboard,
    required this.analysis,
  });

  factory Ada2kSummary.fromJson(Map<String, dynamic> json) {
    return Ada2kSummary(
      user: Ada2kUser.fromJson(json['user']),
      goal: Ada2kGoal.fromJson(json['goal']),
      progress: Ada2kProgress.fromJson(json['progress']),
      cohort: Ada2kCohort.fromJson(json['cohort']),
      status: Ada2kStatus.fromJson(json['status']),
      leaderboard:
          (json['leaderboard'] as List<dynamic>?)
              ?.map((e) => Ada2kLeaderboardEntry.fromJson(e))
              .toList() ??
          [],
      analysis: Ada2kAnalysis.fromJson(
        json['analysis'] ??
            {
              'detailedAnalysis': 'Data not available',
              'recommendation': 'Data not available',
            },
      ),
    );
  }
}

class Ada2kUser {
  final int id;
  final String name;
  final String major;
  final String registrationQuarter;
  final int registrationYear;

  Ada2kUser({
    required this.id,
    required this.name,
    required this.major,
    required this.registrationQuarter,
    required this.registrationYear,
  });

  factory Ada2kUser.fromJson(Map<String, dynamic> json) {
    return Ada2kUser(
      id: json['id'],
      name: json['name'],
      major: json['major'],
      registrationQuarter: json['registrationQuarter'],
      registrationYear: json['registrationYear'],
    );
  }
}

class Ada2kGoal {
  final int targetCompletionPercent;
  final String targetDate;

  Ada2kGoal({required this.targetCompletionPercent, required this.targetDate});

  factory Ada2kGoal.fromJson(Map<String, dynamic> json) {
    return Ada2kGoal(
      targetCompletionPercent: json['targetCompletionPercent'],
      targetDate: json['targetDate'],
    );
  }
}

class Ada2kProgress {
  final int completionPercent;
  final int completedSubjects;
  final int totalSubjects;
  final num averageQuizScore;
  final int onTimeSubjects;
  final int lateSubjects;

  Ada2kProgress({
    required this.completionPercent,
    required this.completedSubjects,
    required this.totalSubjects,
    required this.averageQuizScore,
    required this.onTimeSubjects,
    required this.lateSubjects,
  });

  factory Ada2kProgress.fromJson(Map<String, dynamic> json) {
    return Ada2kProgress(
      completionPercent: json['completionPercent'],
      completedSubjects: json['completedSubjects'],
      totalSubjects: json['totalSubjects'],
      averageQuizScore: json['averageQuizScore'],
      onTimeSubjects: json['onTimeSubjects'],
      lateSubjects: json['lateSubjects'],
    );
  }
}

class Ada2kCohort {
  final int averageCompletionPercent;
  final int studentCount;
  final int percentileEstimate;

  Ada2kCohort({
    required this.averageCompletionPercent,
    required this.studentCount,
    required this.percentileEstimate,
  });

  factory Ada2kCohort.fromJson(Map<String, dynamic> json) {
    return Ada2kCohort(
      averageCompletionPercent: json['averageCompletionPercent'],
      studentCount: json['studentCount'],
      percentileEstimate: json['percentileEstimate'],
    );
  }
}

class Ada2kStatus {
  final String goalStatus;
  final int differenceFromGoal;
  final String insight;

  Ada2kStatus({
    required this.goalStatus,
    required this.differenceFromGoal,
    required this.insight,
  });

  factory Ada2kStatus.fromJson(Map<String, dynamic> json) {
    return Ada2kStatus(
      goalStatus: json['goalStatus'],
      differenceFromGoal: json['differenceFromGoal'],
      insight: json['insight'],
    );
  }
}

class Ada2kLeaderboardEntry {
  final int rank;
  final String name;
  final int score;

  Ada2kLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
  });

  factory Ada2kLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return Ada2kLeaderboardEntry(
      rank: json['rank'],
      name: json['name'],
      score: json['score'],
    );
  }
}

class Ada2kAnalysis {
  final String detailedAnalysis;
  final String recommendation;
  final List<double> performanceHistory;
  final List<String> actionItems;

  const Ada2kAnalysis({
    required this.detailedAnalysis,
    required this.recommendation,
    required this.performanceHistory,
    required this.actionItems,
  });

  factory Ada2kAnalysis.fromJson(Map<String, dynamic> json) {
    return Ada2kAnalysis(
      detailedAnalysis: json['detailedAnalysis'] ?? 'Data not available',
      recommendation: json['recommendation'] ?? 'Data not available',
      performanceHistory:
          (json['performanceHistory'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      actionItems:
          (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
