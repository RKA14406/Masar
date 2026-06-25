import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/quiz_attempt_limit_service.dart';
import '../../core/services/vertex_learning_resource_service.dart';
import '../../core/utils/quiz_achievement_builder.dart';
import '../../data/models/learning_resource_model.dart';
import '../../data/models/quiz_attempt_result_model.dart';
import '../../data/models/subject_model.dart';
import '../quiz/widgets/subject_completion_quiz_sheet.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;
  final String college;
  final String specialization;
  final List<Subject> allSubjects;

  const SubjectDetailsScreen({
    super.key,
    required this.subject,
    required this.college,
    required this.specialization,
    required this.allSubjects,
  });

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  static const String _developerBypassCode = '4406';

  final ProgressService progressService = ProgressService();
  final QuizAttemptLimitService attemptLimitService = QuizAttemptLimitService();
  final VertexLearningResourceService resourceService =
      VertexLearningResourceService();

  bool isCompleted = false;
  bool isLoading = true;
  bool isLoadingResources = true;

  Set<String> completedSubjects = {};
  List<LearningResource> fetchedResources = [];
  String? resourcesError;

  @override
  void initState() {
    super.initState();
    loadScreenData();
  }

  Future<void> loadScreenData() async {
    await Future.wait([
      loadCompletionData(),
      loadResources(),
    ]);
  }

  Future<void> loadCompletionData() async {
    final completed = await progressService.getCompletedSubjects(
      widget.specialization,
    );

    if (!mounted) return;

    setState(() {
      completedSubjects = completed;
      isCompleted = completed.contains(widget.subject.code);
      isLoading = false;
    });
  }

  Future<void> loadResources() async {
    if (!mounted) return;

    setState(() {
      isLoadingResources = true;
      resourcesError = null;
    });

    try {
      final resources = await resourceService.searchResourcesForSubject(
        widget.subject,
      );

      if (!mounted) return;

      setState(() {
        fetchedResources = resources;
        isLoadingResources = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resourcesError = e.toString();
        isLoadingResources = false;
      });
    }
  }

  Future<void> toggleCompletion(bool value) async {
    if (!value) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.subject.name} is already completed and cannot be uncompleted.',
          ),
        ),
      );
      return;
    }

    if (isCompleted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.subject.name} is already completed.'),
        ),
      );
      return;
    }

    final result = await _attemptCompletionQuiz();

    if (result == null) return;

    if (result.passed) {
      await progressService.markCompleted(
        widget.specialization,
        widget.subject.code,
      );
      await loadCompletionData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.subject.name} marked as completed after passing the quiz.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final failureMessage = result.integrityPassed
        ? 'Quiz score ${result.scorePercent.toStringAsFixed(1)}%. You need 60% to complete this subject.'
        : 'Integrity violation detected during the quiz. App switching is not allowed.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(failureMessage),
      ),
    );
  }

  Future<QuizAttemptResult?> _attemptCompletionQuiz() async {
    final canStart = await attemptLimitService.canStartAttempt(
      specialization: widget.specialization,
      subjectCode: widget.subject.code,
    );

    if (!canStart) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Daily attempt limit reached for ${widget.subject.name}. You can try again tomorrow.',
          ),
        ),
      );
      return null;
    }

    await attemptLimitService.registerAttempt(
      specialization: widget.specialization,
      subjectCode: widget.subject.code,
    );

    final achievementsSummary = QuizAchievementBuilder.build(
      allSubjects: widget.allSubjects,
      completedSubjectCodes: completedSubjects,
    );

    return showSubjectCompletionQuiz(
      context: context,
      subject: widget.subject,
      college: widget.college,
      specialization: widget.specialization,
      achievementsSummary: achievementsSummary,
    );
  }

  Future<void> _showDeveloperSkipDialog() async {
    if (isCompleted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.subject.name} is already completed.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    var enteredCode = '';

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Developer bypass'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the developer code to skip this subject and mark it as completed.',
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Developer code',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  enteredCode = value.trim();
                },
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  FocusScope.of(dialogContext).unfocus();
                  Navigator.of(dialogContext).pop(trimmed);
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'This bypass ignores quiz, attempts, and prerequisites. Use it only for development.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(enteredCode);
              },
              child: const Text('Skip Subject'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    FocusScope.of(context).unfocus();

    if (result == null || result.isEmpty) {
      return;
    }

    if (result != _developerBypassCode) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Wrong developer code.'),
        ),
      );
      return;
    }

    await progressService.markCompleted(
      widget.specialization,
      widget.subject.code,
    );
    await loadCompletionData();

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${widget.subject.name} was force-completed using developer bypass.',
        ),
      ),
    );
  }

  List<Subject> getPrerequisiteSubjects() {
    return widget.allSubjects
        .where((s) => widget.subject.prerequisites.contains(s.code))
        .toList();
  }

  List<Subject> getMissingPrerequisiteSubjects() {
    return getPrerequisiteSubjects()
        .where((s) => !completedSubjects.contains(s.code))
        .toList();
  }

  bool isUnlocked() {
    return getMissingPrerequisiteSubjects().isEmpty;
  }

  Color getStatusColor() {
    if (isCompleted) return Colors.green;
    if (!isUnlocked()) return Colors.orange;
    return Colors.blue;
  }

  String getStatusText() {
    if (isCompleted) return 'Completed';
    if (!isUnlocked()) return 'Locked';
    return 'Ready to complete';
  }

  String getLockedReason() {
    final missing = getMissingPrerequisiteSubjects();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (missing.isEmpty) {
      return isArabic ? 'تم إكمال جميع المتطلبات السابقة.' : 'All prerequisites completed.';
    }

    final names = missing.map((e) => (isArabic && e.nameAr != null) ? e.nameAr : e.name).join(', ');
    return isArabic ? 'أكمل هذه أولاً: $names' : 'Complete these first: $names';
  }

  String getStatusDescription() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isCompleted) {
      return isArabic ? 'لقد أكملت هذه المادة بالفعل.' : 'You already completed this subject.';
    }

    if (isUnlocked()) {
      return isArabic ? 'يمكنك الآن التقدم لاختبار الإكمال.' : 'You can now take the completion quiz.';
    }

    return getLockedReason();
  }

  IconData getStatusIcon() {
    if (isCompleted) return Icons.check_circle;
    if (!isUnlocked()) return Icons.lock;
    return Icons.play_circle_fill;
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open resource link')),
      );
    }
  }

  Widget buildResourcesSection(Subject subject) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Recommended Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: loadResources,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (_) {
                if (isLoadingResources) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (resourcesError != null) {
                  return Text(resourcesError!);
                }

                if (fetchedResources.isEmpty) {
                  return const Text('No resources found.');
                }

                return Column(
                  children: fetchedResources.map((resource) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => openUrl(resource.url),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.platform,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                resource.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = (isArabic && subject.nameAr != null && subject.nameAr!.isNotEmpty)
        ? subject.nameAr!
        : subject.name;
    final displayDescription = (isArabic && subject.descriptionAr != null && subject.descriptionAr!.isNotEmpty)
        ? subject.descriptionAr!
        : subject.description;
        
    final prereqSubjects = getPrerequisiteSubjects();
    final missingPrereqs = getMissingPrerequisiteSubjects();
    final unlocked = isUnlocked();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.code),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(getStatusIcon(), color: getStatusColor()),
                      const SizedBox(width: 8),
                      Text(
                        'Status: ${getStatusText()}',
                        style: TextStyle(
                          color: getStatusColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Code: ${subject.code}'),
                          const SizedBox(height: 8),
                          Text('Credits: ${subject.credits}'),
                          const SizedBox(height: 8),
                          Text('Phase: ${subject.phase}'),
                          const SizedBox(height: 8),
                          Text('Specialization: ${isArabic && subject.specializationAr != null ? subject.specializationAr : subject.specialization}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${getStatusText()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(getStatusDescription()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: !unlocked || isCompleted
                                  ? null
                                  : () => toggleCompletion(true),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark as Completed'),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isCompleted
                                  ? () async {
                                      await progressService.markUncompleted(
                                        widget.specialization,
                                        widget.subject.code,
                                      );

                                      await loadCompletionData();

                                      if (!mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${widget.subject.name} marked as uncompleted.',
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.undo),
                              label: const Text('Uncomplete Subject'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isCompleted ? null : _showDeveloperSkipDialog,
                              icon: const Icon(Icons.code_rounded),
                              label: const Text('Developer Skip'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Prerequisites',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (prereqSubjects.isEmpty)
                    const Text('None')
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: prereqSubjects.map((prereq) {
                            final done = completedSubjects.contains(prereq.code);
                            final pName = (isArabic && prereq.nameAr != null) ? prereq.nameAr! : prereq.name;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    done
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: done ? Colors.green : Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(pName)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (missingPrereqs.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Missing prerequisites',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: missingPrereqs
                              .map((s) {
                                final mName = (isArabic && s.nameAr != null) ? s.nameAr! : s.name;
                                return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text('• $mName (${s.code})'),
                                  );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        displayDescription.trim().isEmpty
                            ? 'No description available yet.'
                            : displayDescription,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildResourcesSection(subject),
                  const SizedBox(height: 24),
                  const Text(
                    'Related Skills',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: subject.skills.isEmpty
                          ? const Text('No skills added yet.')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: subject.skills
                                  .map((skill) => Chip(label: Text(skill)))
                                  .toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
