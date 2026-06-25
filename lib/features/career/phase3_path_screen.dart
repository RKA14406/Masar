import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/career_storage_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/quiz_attempt_limit_service.dart';
import '../../core/utils/quiz_achievement_builder.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/quiz_attempt_result_model.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import '../quiz/widgets/subject_completion_quiz_sheet.dart';
import '../subject_details/subject_details_screen.dart';
import 'career_summary_screen.dart';

class Phase3PathScreen extends StatefulWidget {
  final String college;
  final String specialization;

  const Phase3PathScreen({
    super.key,
    required this.college,
    required this.specialization,
  });

  @override
  State<Phase3PathScreen> createState() => _Phase3PathScreenState();
}

class _Phase3PathScreenState extends State<Phase3PathScreen> {
  final CareerStorageService _careerStorageService = CareerStorageService();
  final ProgressService _progressService = ProgressService();
  final QuizAttemptLimitService _attemptLimitService = QuizAttemptLimitService();

  late final SubjectRepository _repository;

  List<Subject> _baseSubjects = [];
  List<Subject> _phase3Nodes = [];
  Set<String> _completedCodes = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = SubjectRepository(
      localDataSource: SubjectLocalDataSource(),
    );
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    try {
      final results = await Future.wait([
        _repository.getSubjectsByCollegeAndSpecialization(
          college: widget.college,
          specialization: widget.specialization,
        ),
        _careerStorageService.loadGeneratedNodes(
          college: widget.college,
          specialization: widget.specialization,
        ),
        _progressService.getCompletedSubjects(widget.specialization),
      ]);

      setState(() {
        _baseSubjects = results[0] as List<Subject>;
        _phase3Nodes = results[1] as List<Subject>;
        _completedCodes = results[2] as Set<String>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  bool _isCompleted(Subject subject) => _completedCodes.contains(subject.code);

  bool _isUnlocked(Subject subject) {
    if (subject.prerequisites.isEmpty) return true;
    return subject.prerequisites.every(_completedCodes.contains);
  }

  List<Subject> _missingPrerequisites(Subject subject) {
    return _phase3Nodes
        .where(
          (candidate) =>
      subject.prerequisites.contains(candidate.code) &&
          !_completedCodes.contains(candidate.code),
    )
        .toList(growable: false);
  }

  Future<void> _openNode(Subject subject) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetailsScreen(
          subject: subject,
          college: widget.college,
          specialization: widget.specialization,
          allSubjects: [..._baseSubjects, ..._phase3Nodes],
        ),
      ),
    );

    await _loadScreen();
  }

  Future<void> _completeNodeFromLongPress(Subject subject) async {
    final l10n = AppLocalizations.of(context)!;

    if (_isCompleted(subject)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.phase3_already_completed(subject.name)),
        ),
      );
      return;
    }

    if (!_isUnlocked(subject)) {
      final names = _missingPrerequisites(subject).map((e) => e.name).join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.phase3_locked_first(names)),
        ),
      );
      return;
    }

    final result = await _attemptCompletionQuiz(subject);
    if (result == null) return;

    if (!result.passed) {
      final failureMessage = result.integrityPassed
          ? l10n.phase3_quiz_failed_score(
          result.scorePercent.toStringAsFixed(1), subject.name)
          : l10n.phase3_quiz_integrity(subject.name);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failureMessage)),
      );
      return;
    }

    await _progressService.markCompleted(widget.specialization, subject.code);
    await _loadScreen();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.phase3_marked_completed(subject.name)),
      ),
    );
  }

  Future<QuizAttemptResult?> _attemptCompletionQuiz(Subject subject) async {
    final l10n = AppLocalizations.of(context)!;

    final canStart = await _attemptLimitService.canStartAttempt(
      specialization: widget.specialization,
      subjectCode: subject.code,
    );

    if (!canStart) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.phase3_attempt_limit(subject.name)),
        ),
      );
      return null;
    }

    await _attemptLimitService.registerAttempt(
      specialization: widget.specialization,
      subjectCode: subject.code,
    );

    final achievementsSummary = QuizAchievementBuilder.build(
      allSubjects: [..._baseSubjects, ..._phase3Nodes],
      completedSubjectCodes: _completedCodes,
    );

    return showSubjectCompletionQuiz(
      context: context,
      subject: subject,
      college: widget.college,
      specialization: widget.specialization,
      achievementsSummary: achievementsSummary,
    );
  }

  bool get _allCompleted =>
      _phase3Nodes.isNotEmpty && _phase3Nodes.every(_isCompleted);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phase3_title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    if (_phase3Nodes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.phase3_title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              l10n.phase3_empty,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phase3_title),
        actions: [
          if (_allCompleted)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CareerSummaryScreen(
                      college: widget.college,
                      specialization: widget.specialization,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.workspace_premium),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.phase3_header,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.phase3_description),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _phase3Nodes.length,
              itemBuilder: (context, index) {
                final node = _phase3Nodes[index];
                final isCompleted = _isCompleted(node);
                final isUnlocked = _isUnlocked(node);
                final relatedJobs = _extractRelatedJobs(node.description);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _openNode(node),
                    onLongPress: () => _completeNodeFromLongPress(node),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green
                              : isUnlocked
                              ? Theme.of(context).colorScheme.primary
                              : Colors.orange,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  node.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : isUnlocked
                                    ? Icons.lock_open
                                    : Icons.lock,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            node.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: node.skills
                                .map((skill) => Chip(label: Text(skill)))
                                .toList(growable: false),
                          ),
                          if (relatedJobs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              l10n.phase3_related_jobs(relatedJobs.join(', ')),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            isCompleted
                                ? l10n.phase3_status_completed
                                : isUnlocked
                                ? l10n.phase3_status_unlocked
                                : l10n.phase3_status_locked,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_allCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CareerSummaryScreen(
                          college: widget.college,
                          specialization: widget.specialization,
                        ),
                      ),
                    );
                  },
                  child: Text(l10n.phase3_open_summary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> _extractRelatedJobs(String description) {
    final marker = 'Related jobs:';
    final index = description.indexOf(marker);
    if (index == -1) return const [];

    final related = description.substring(index + marker.length).trim();
    return related
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}