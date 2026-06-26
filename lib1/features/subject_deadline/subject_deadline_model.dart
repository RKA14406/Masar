class SubjectDeadline {
  final String subjectId;
  final DateTime startDate;
  final DateTime targetDate;
  final int targetMonths;
  final bool completedOnTime;
  final bool completedLate;
  final int deadlineBonus;

  const SubjectDeadline({
    required this.subjectId,
    required this.startDate,
    required this.targetDate,
    required this.targetMonths,
    this.completedOnTime = false,
    this.completedLate = false,
    this.deadlineBonus = 0,
  });

  factory SubjectDeadline.fromJson(Map<String, dynamic> json) {
    return SubjectDeadline(
      subjectId: (json['subjectId'] ?? '').toString(),
      startDate:
          DateTime.tryParse((json['startDate'] ?? '').toString()) ??
          DateTime.now(),
      targetDate:
          DateTime.tryParse((json['targetDate'] ?? '').toString()) ??
          DateTime.now(),
      targetMonths: (json['targetMonths'] as num?)?.toInt() ?? 0,
      completedOnTime: json['completedOnTime'] == true,
      completedLate: json['completedLate'] == true,
      deadlineBonus: (json['deadlineBonus'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'targetMonths': targetMonths,
      'completedOnTime': completedOnTime,
      'completedLate': completedLate,
      'deadlineBonus': deadlineBonus,
    };
  }

  SubjectDeadline copyWith({
    DateTime? startDate,
    DateTime? targetDate,
    int? targetMonths,
    bool? completedOnTime,
    bool? completedLate,
    int? deadlineBonus,
  }) {
    return SubjectDeadline(
      subjectId: subjectId,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      targetMonths: targetMonths ?? this.targetMonths,
      completedOnTime: completedOnTime ?? this.completedOnTime,
      completedLate: completedLate ?? this.completedLate,
      deadlineBonus: deadlineBonus ?? this.deadlineBonus,
    );
  }
}

class DeadlineScoreSummary {
  final int onTimeSubjects;
  final int lateSubjects;
  final int deadlineBonusScore;

  const DeadlineScoreSummary({
    required this.onTimeSubjects,
    required this.lateSubjects,
    required this.deadlineBonusScore,
  });
}
