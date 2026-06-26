import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/repositories/subject_repository.dart';
import '../general_quiz/general_quiz_storage_service.dart';
import '../seven_sabak/personal_info_storage_service.dart';
import '../subject_deadline/subject_deadline_service.dart';
import 'ada2k_model.dart';

class Ada2kService {
  static const String baseUrl = 'http://10.0.2.2:10000/api';
  static const String _goalPercentKey = 'ada2k_goal_percent';
  static const String _goalDateKey = 'ada2k_goal_date';

  final ProgressService _progressService;
  final SubjectRepository _subjectRepository;
  final SubjectDeadlineService _deadlineService;
  final GeneralQuizStorageService _generalQuizStorage;
  final PersonalInfoStorageService _personalInfoStorage;

  Ada2kService({
    ProgressService? progressService,
    SubjectRepository? subjectRepository,
    SubjectDeadlineService? deadlineService,
    GeneralQuizStorageService? generalQuizStorage,
    PersonalInfoStorageService? personalInfoStorage,
  }) : _progressService = progressService ?? ProgressService(),
       _subjectRepository =
           subjectRepository ??
           SubjectRepository(localDataSource: SubjectLocalDataSource()),
       _deadlineService = deadlineService ?? SubjectDeadlineService(),
       _generalQuizStorage = generalQuizStorage ?? GeneralQuizStorageService(),
       _personalInfoStorage =
           personalInfoStorage ?? PersonalInfoStorageService();

  Future<Ada2kSummary?> fetchSummary(int userId) async {
    final localSummary = await _buildLocalSummary(userId);

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/ada2k/summary/$userId'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode != 200) {
        debugPrint('Ada2k backend skipped: HTTP ${response.statusCode}');
        return localSummary;
      }

      final remoteSummary = Ada2kSummary.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      return Ada2kSummary(
        user: localSummary.user,
        goal: localSummary.goal,
        progress: localSummary.progress,
        cohort: remoteSummary.cohort,
        status: _buildStatus(localSummary.progress, localSummary.goal),
        leaderboard: _mergeLeaderboard(localSummary, remoteSummary),
        analysis: _buildAnalysis(localSummary),
      );
    } on TimeoutException {
      debugPrint('Ada2k backend timed out, using local Masar data.');
      return localSummary;
    } catch (error) {
      debugPrint('Ada2k backend unavailable, using local Masar data: $error');
      return localSummary;
    }
  }

  Future<bool> updateGoal(
    int userId,
    int targetPercent,
    String targetDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalPercentKey, targetPercent);
    await prefs.setString(_goalDateKey, targetDate);

    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/ada2k/goal/$userId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'targetCompletionPercent': targetPercent,
              'targetDate': targetDate,
            }),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (error) {
      debugPrint('Ada2k goal saved locally; backend sync skipped: $error');
      return true;
    }
  }

  Future<Ada2kSummary> _buildLocalSummary(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final selectedTrack = await _progressService.getSelectedTrack();
    final personalInfo = await _personalInfoStorage.load();
    final profile = await UserProfileService().getCurrentUserProfile();

    final specialization =
        selectedTrack?.specialization.trim().isNotEmpty == true
        ? selectedTrack!.specialization.trim()
        : (personalInfo?.major.trim() ?? '');
    final college = selectedTrack?.college.trim() ?? '';

    final subjects = specialization.isEmpty
        ? await _subjectRepository.getAllSubjects()
        : await _subjectRepository.getSubjectsByCollegeAndSpecialization(
            college: college,
            specialization: specialization,
          );
    final completedCodes = specialization.isEmpty
        ? <String>{}
        : await _progressService.getCompletedSubjects(specialization);
    final completedCount = subjects
        .where((subject) => completedCodes.contains(subject.code))
        .length;
    final totalCount = subjects.isEmpty
        ? completedCodes.length
        : subjects.length;
    final completionPercent = totalCount == 0
        ? 0
        : ((completedCount / totalCount) * 100).round().clamp(0, 100);

    final deadlineScore = await _deadlineService.getScoreSummary();
    final generalQuiz = specialization.isEmpty
        ? null
        : await _generalQuizStorage.loadStatus(specialization);

    final goal = Ada2kGoal(
      targetCompletionPercent: prefs.getInt(_goalPercentKey) ?? 70,
      targetDate:
          prefs.getString(_goalDateKey) ??
          DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now().add(const Duration(days: 90))),
    );
    final progress = Ada2kProgress(
      completionPercent: completionPercent,
      completedSubjects: completedCount,
      totalSubjects: totalCount,
      averageQuizScore: generalQuiz?.latestScore ?? 0,
      onTimeSubjects: deadlineScore.onTimeSubjects,
      lateSubjects: deadlineScore.lateSubjects,
    );
    final summary = Ada2kSummary(
      user: Ada2kUser(
        id: userId,
        name: _firstNonEmpty([
          personalInfo?.fullName,
          profile?['username']?.toString(),
          profile?['name']?.toString(),
          'Student',
        ]),
        major: _firstNonEmpty([
          personalInfo?.major,
          specialization,
          'Not selected',
        ]),
        registrationQuarter: _firstNonEmpty([
          personalInfo?.enrollmentQuarter,
          'Q1',
        ]),
        registrationYear:
            int.tryParse((personalInfo?.enrollmentYear ?? '').trim()) ??
            DateTime.now().year,
      ),
      goal: goal,
      progress: progress,
      cohort: _buildLocalCohort(completionPercent),
      status: _buildStatus(progress, goal),
      leaderboard: const [],
      analysis: const Ada2kAnalysis(
        detailedAnalysis: '',
        recommendation: '',
        performanceHistory: [],
        actionItems: [],
      ),
    );

    return Ada2kSummary(
      user: summary.user,
      goal: summary.goal,
      progress: summary.progress,
      cohort: summary.cohort,
      status: summary.status,
      leaderboard: _buildLocalLeaderboard(summary),
      analysis: _buildAnalysis(summary),
    );
  }

  Ada2kCohort _buildLocalCohort(int completionPercent) {
    final average = completionPercent < 20 ? 25 : 55;
    final percentile = completionPercent >= average
        ? 65 + ((completionPercent - average) / 2).round()
        : 35 - ((average - completionPercent) / 3).round();

    return Ada2kCohort(
      averageCompletionPercent: average,
      studentCount: 1,
      percentileEstimate: percentile.clamp(1, 99),
    );
  }

  Ada2kStatus _buildStatus(Ada2kProgress progress, Ada2kGoal goal) {
    final difference =
        progress.completionPercent - goal.targetCompletionPercent;
    final status = difference >= 0
        ? 'On track'
        : difference >= -10
        ? 'Slightly behind'
        : 'Needs attention';
    final insight = difference >= 0
        ? 'You are meeting your current Ada2k completion goal.'
        : 'You are $difference% below your goal. Complete the next available subject or adjust the goal date.';

    return Ada2kStatus(
      goalStatus: status,
      differenceFromGoal: difference,
      insight: insight,
    );
  }

  List<Ada2kLeaderboardEntry> _mergeLeaderboard(
    Ada2kSummary local,
    Ada2kSummary remote,
  ) {
    if (remote.leaderboard.isEmpty) return _buildLocalLeaderboard(local);

    final entries = [...remote.leaderboard];
    final existingUser = entries.indexWhere(
      (entry) => entry.name.toLowerCase() == local.user.name.toLowerCase(),
    );
    final currentUserEntry = Ada2kLeaderboardEntry(
      rank: existingUser == -1
          ? entries.length + 1
          : entries[existingUser].rank,
      name: local.user.name,
      score: _scoreFromProgress(local.progress),
    );

    if (existingUser == -1) {
      entries.add(currentUserEntry);
    } else {
      entries[existingUser] = currentUserEntry;
    }

    entries.sort((a, b) => b.score.compareTo(a.score));
    return [
      for (var i = 0; i < entries.length; i++)
        Ada2kLeaderboardEntry(
          rank: i + 1,
          name: entries[i].name,
          score: entries[i].score,
        ),
    ];
  }

  List<Ada2kLeaderboardEntry> _buildLocalLeaderboard(Ada2kSummary summary) {
    final currentScore = _scoreFromProgress(summary.progress);
    final baselines = <Ada2kLeaderboardEntry>[
      Ada2kLeaderboardEntry(rank: 1, name: 'Cohort benchmark', score: 78),
      Ada2kLeaderboardEntry(rank: 2, name: 'Active learner', score: 63),
      Ada2kLeaderboardEntry(rank: 3, name: 'Getting started', score: 35),
      Ada2kLeaderboardEntry(
        rank: 4,
        name: summary.user.name,
        score: currentScore,
      ),
    ];

    baselines.sort((a, b) => b.score.compareTo(a.score));
    return [
      for (var i = 0; i < baselines.length; i++)
        Ada2kLeaderboardEntry(
          rank: i + 1,
          name: baselines[i].name,
          score: baselines[i].score,
        ),
    ];
  }

  Ada2kAnalysis _buildAnalysis(Ada2kSummary summary) {
    final progress = summary.progress;
    final actions = <String>[];

    if (progress.totalSubjects == 0) {
      actions.add('Choose a career path in Masark to start tracking Ada2k.');
    }
    if (progress.completedSubjects == 0 && progress.totalSubjects > 0) {
      actions.add(
        'Complete your first subject to activate stronger comparisons.',
      );
    }
    if (progress.completionPercent < summary.goal.targetCompletionPercent) {
      actions.add(
        'Finish the next available subject or adjust your goal date.',
      );
    }
    if (progress.averageQuizScore == 0) {
      actions.add('Take the General Quiz to add major-level evidence.');
    }
    if (progress.onTimeSubjects == 0) {
      actions.add('Set deadlines on subjects to earn deadline bonus points.');
    }
    if (actions.isEmpty) {
      actions.add('Keep your current pace and set a higher target when ready.');
    }

    final detailed =
        'Ada2k is using your saved Masar progress: '
        '${progress.completedSubjects} of ${progress.totalSubjects} subjects completed, '
        '${progress.onTimeSubjects} on-time deadline completions, '
        '${progress.lateSubjects} late completions, and latest General Quiz score '
        '${progress.averageQuizScore}%.';

    return Ada2kAnalysis(
      detailedAnalysis: detailed,
      recommendation: actions.first,
      performanceHistory: _buildTrend(progress.completionPercent),
      actionItems: actions,
    );
  }

  List<double> _buildTrend(int completionPercent) {
    if (completionPercent <= 0) return [0, 0, 0, 0, 0, 0];
    return [
      for (var i = 1; i <= 6; i++)
        (completionPercent * (i / 6)).clamp(0, 100).toDouble(),
    ];
  }

  int _scoreFromProgress(Ada2kProgress progress) {
    final quizScore = progress.averageQuizScore.round();
    final deadlineScore = progress.onTimeSubjects * 3;
    return (progress.completionPercent +
            (quizScore / 5).round() +
            deadlineScore)
        .clamp(0, 100);
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }
}
