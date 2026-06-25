import 'package:flutter/material.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/quiz_attempt_limit_service.dart';
import '../../core/utils/path_generator.dart';
import '../../core/utils/quiz_achievement_builder.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/quiz_attempt_result_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import '../quiz/widgets/subject_completion_quiz_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXTENSION
// ─────────────────────────────────────────────────────────────────────────────
extension SubjectLocalization on Subject {
  String localizedName(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    if (isRtl && nameAr != null && nameAr!.isNotEmpty) return nameAr!;
    return name;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENUM
// ─────────────────────────────────────────────────────────────────────────────
enum NodeVisualState { locked, unlocked, completed }

// ─────────────────────────────────────────────────────────────────────────────
// CONTROLLER
// ─────────────────────────────────────────────────────────────────────────────
class PathViewController extends ChangeNotifier {
  PathViewController({
    required this.college,
    required this.specialization,
  })  : _repository =
  SubjectRepository(localDataSource: SubjectLocalDataSource()),
        _progressService = ProgressService(),
        _attemptLimitService = QuizAttemptLimitService();

  final String college;
  final String specialization;

  final SubjectRepository _repository;
  final ProgressService _progressService;
  final QuizAttemptLimitService _attemptLimitService;

  // ── STATE ──────────────────────────────────────────────────────────
  bool isLoading = true;
  String? errorMessage;

  List<Subject> allSubjects = [];
  List<Subject> phase1Subjects = [];
  List<Subject> phase2Subjects = [];
  Set<String> completedSubjects = {};
  Subject? selectedSubject;

  double progressPercent = 0;
  bool phase1And2Completed = false;

  // ──────────────────────────────────────────────────────────────────
  // LOAD PATH
  // ──────────────────────────────────────────────────────────────────
  Future<void> loadPath() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final subjects =
      await _repository.getSubjectsByCollegeAndSpecialization(
        college: college,
        specialization: specialization,
      );

      final ordered = PathGenerator.generateOrderedPath(subjects);
      final completed =
      await _progressService.getCompletedSubjects(specialization);

      final lastCode =
      await _progressService.getLastOpenedSubject(specialization);

      allSubjects = ordered;
      phase1Subjects =
          ordered.where((s) => s.phase == 1).toList(growable: false);
      phase2Subjects =
          ordered.where((s) => s.phase == 2).toList(growable: false);
      completedSubjects = completed;

      // 🔥 SAFE RESTORE
      Subject? restored;
      if (lastCode != null) {
        try {
          restored = ordered.firstWhere((s) => s.code == lastCode);
        } catch (_) {
          restored = null;
        }
      }

      selectedSubject =
          restored ?? (ordered.isNotEmpty ? ordered.first : null);

      isLoading = false;
      errorMessage = null;

      _recomputeDerived();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // OPEN SUBJECT (CRITICAL FIX)
  // ──────────────────────────────────────────────────────────────────
  Future<void> openSubject(Subject subject) async {
    selectedSubject = subject;

    await _progressService.setLastOpenedSubject(
      specialization,
      subject.code,
    );

    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────
  // NODE STATE
  // ──────────────────────────────────────────────────────────────────
  NodeVisualState nodeStateFor(Subject subject) {
    if (completedSubjects.contains(subject.code)) {
      return NodeVisualState.completed;
    }
    if (_isUnlocked(subject)) return NodeVisualState.unlocked;
    return NodeVisualState.locked;
  }

  bool _isUnlocked(Subject subject) {
    if (subject.prerequisites.isEmpty) return true;
    return subject.prerequisites.every(completedSubjects.contains);
  }

  List<Subject> missingPrerequisitesFor(Subject subject) {
    return allSubjects.where((candidate) {
      return subject.prerequisites.contains(candidate.code) &&
          !completedSubjects.contains(candidate.code);
    }).toList(growable: false);
  }

  // ──────────────────────────────────────────────────────────────────
  // QUIZ
  // ──────────────────────────────────────────────────────────────────
  Future<QuizAttemptResult?> attemptCompletionQuiz({
    required Subject subject,
    required BuildContext context,
  }) async {
    final canStart = await _attemptLimitService.canStartAttempt(
      specialization: specialization,
      subjectCode: subject.code,
    );

    if (!canStart) {
      if (!context.mounted) return null;
      _showSnackBar(
        context,
        'Daily attempt limit reached for ${subject.name}.',
      );
      return null;
    }

    await _attemptLimitService.registerAttempt(
      specialization: specialization,
      subjectCode: subject.code,
    );

    final achievements = QuizAchievementBuilder.build(
      allSubjects: allSubjects,
      completedSubjectCodes: completedSubjects,
    );

    if (!context.mounted) return null;

    return showSubjectCompletionQuiz(
      context: context,
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievements,
    );
  }

  Future<void> markCompleted(Subject subject) async {
    await _progressService.markCompleted(specialization, subject.code);

    completedSubjects =
    await _progressService.getCompletedSubjects(specialization);

    selectedSubject = subject;

    _recomputeDerived();
  }

  // ──────────────────────────────────────────────────────────────────
  // DERIVED
  // ──────────────────────────────────────────────────────────────────
  void _recomputeDerived() {
    final allPhase = [...phase1Subjects, ...phase2Subjects];

    final total = allPhase.length;
    final done =
        allPhase.where((s) => completedSubjects.contains(s.code)).length;

    progressPercent = total == 0 ? 0 : done / total;

    phase1And2Completed =
        total > 0 && allPhase.every((s) => completedSubjects.contains(s.code));

    notifyListeners();
  }

  List<Subject> get completedSubjectsList =>
      allSubjects.where((s) => completedSubjects.contains(s.code)).toList();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}