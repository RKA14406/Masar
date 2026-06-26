import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/progress_service.dart';
import '../../core/services/quiz_attempt_limit_service.dart';
import '../../core/services/vertex_learning_resource_service.dart';
import '../../core/utils/quiz_achievement_builder.dart';
import '../../data/models/learning_resource_model.dart';
import '../../data/models/quiz_attempt_result_model.dart';
import '../../data/models/subject_model.dart';
import '../../l10n/masar_text.dart';
import '../subject_deadline/subject_deadline_model.dart';
import '../subject_deadline/subject_deadline_service.dart';
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
  final SubjectDeadlineService deadlineService = SubjectDeadlineService();
  final VertexLearningResourceService resourceService =
      VertexLearningResourceService();

  bool isCompleted = false;
  bool isLoading = true;
  bool isLoadingResources = true;

  Set<String> completedSubjects = {};
  List<LearningResource> fetchedResources = [];
  String? resourcesError;
  SubjectDeadline? deadline;

  @override
  void initState() {
    super.initState();
    loadScreenData();
  }

  Future<void> loadScreenData() async {
    await Future.wait([
      loadCompletionData(),
      loadDeadlineData(),
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

  String get _deadlineSubjectId =>
      '${widget.specialization.trim()}::${widget.subject.code.trim()}';

  String _localizedSubjectName(Subject subject) {
    final isArabic = MasarText.isArabic(context);
    if (isArabic && subject.nameAr != null && subject.nameAr!.isNotEmpty) {
      return subject.nameAr!;
    }
    return subject.name;
  }

  Future<void> loadDeadlineData() async {
    final saved = await deadlineService.getDeadline(_deadlineSubjectId);
    if (!mounted) return;

    setState(() {
      deadline = saved;
    });
  }

  Future<void> _setDeadlineMonths(int months) async {
    final saved = await deadlineService.setMonthTarget(
      subjectId: _deadlineSubjectId,
      months: months,
    );
    if (!mounted) return;

    setState(() {
      deadline = saved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          MasarText.t(
            context,
            'Learning target set to $months month(s).',
            'تم تحديد هدف التعلم لمدة $months شهر.',
          ),
        ),
      ),
    );
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
            MasarText.t(
              context,
              '${widget.subject.name} is already completed and cannot be uncompleted.',
              '${_localizedSubjectName(widget.subject)} مكتملة بالفعل ولا يمكن إلغاء إكمالها من هنا.',
            ),
          ),
        ),
      );
      return;
    }

    if (isCompleted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              '${widget.subject.name} is already completed.',
              '${_localizedSubjectName(widget.subject)} مكتملة بالفعل.',
            ),
          ),
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
      await deadlineService.recordCompletion(_deadlineSubjectId);
      await loadCompletionData();
      await loadDeadlineData();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              '${widget.subject.name} marked as completed after passing the quiz.',
              'تم إكمال ${_localizedSubjectName(widget.subject)} بعد اجتياز الاختبار.',
            ),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    final failureMessage = result.integrityPassed
        ? MasarText.t(
            context,
            'Quiz score ${result.scorePercent.toStringAsFixed(1)}%. You need 60% to complete this subject.',
            'نتيجة الاختبار ${result.scorePercent.toStringAsFixed(1)}%. تحتاج إلى 60% لإكمال هذه المادة.',
          )
        : MasarText.t(
            context,
            'Integrity violation detected during the quiz. App switching is not allowed.',
            'تم اكتشاف مخالفة أثناء الاختبار. لا يُسمح بتبديل التطبيق.',
          );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failureMessage)));
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
            MasarText.t(
              context,
              'Daily attempt limit reached for ${widget.subject.name}. You can try again tomorrow.',
              'وصلت إلى الحد اليومي لمحاولات ${_localizedSubjectName(widget.subject)}. يمكنك المحاولة غداً.',
            ),
          ),
        ),
      );
      return null;
    }

    await attemptLimitService.registerAttempt(
      specialization: widget.specialization,
      subjectCode: widget.subject.code,
    );

    if (!mounted) return null;

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
          content: Text(
            MasarText.t(
              context,
              '${widget.subject.name} is already completed.',
              '${_localizedSubjectName(widget.subject)} مكتملة بالفعل.',
            ),
          ),
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
          title: Text(MasarText.t(context, 'Developer bypass', 'تجاوز المطور')),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MasarText.t(
                  context,
                  'Enter the developer code to skip this subject and mark it as completed.',
                  'أدخل رمز المطور لتجاوز هذه المادة ووضعها كمكتملة.',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: MasarText.t(
                    context,
                    'Developer code',
                    'رمز المطور',
                  ),
                  border: const OutlineInputBorder(),
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
              Text(
                MasarText.t(
                  context,
                  'This bypass ignores quiz, attempts, and prerequisites. Use it only for development.',
                  'هذا التجاوز يتخطى الاختبار والمحاولات والمتطلبات. استخدمه للتطوير فقط.',
                ),
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
              child: Text(MasarText.t(context, 'Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(enteredCode);
              },
              child: Text(MasarText.t(context, 'Skip Subject', 'تجاوز المادة')),
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
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Wrong developer code.',
              'رمز المطور غير صحيح.',
            ),
          ),
        ),
      );
      return;
    }

    await progressService.markCompleted(
      widget.specialization,
      widget.subject.code,
    );
    await deadlineService.recordCompletion(_deadlineSubjectId);
    await loadCompletionData();
    await loadDeadlineData();

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          MasarText.t(
            context,
            '${widget.subject.name} was force-completed using developer bypass.',
            'تم إكمال ${_localizedSubjectName(widget.subject)} باستخدام تجاوز المطور.',
          ),
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
    if (isCompleted) return MasarText.t(context, 'Completed', 'مكتمل');
    if (!isUnlocked()) return MasarText.t(context, 'Locked', 'مغلق');
    return MasarText.t(context, 'Ready to complete', 'جاهز للإكمال');
  }

  String getLockedReason() {
    final missing = getMissingPrerequisiteSubjects();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (missing.isEmpty) {
      return MasarText.t(
        context,
        'All prerequisites completed.',
        'تم إكمال جميع المتطلبات السابقة.',
      );
    }

    final names = missing
        .map((e) => (isArabic && e.nameAr != null) ? e.nameAr : e.name)
        .join(', ');
    return MasarText.t(
      context,
      'Complete these first: $names',
      'أكمل هذه أولاً: $names',
    );
  }

  String getStatusDescription() {
    if (isCompleted) {
      return MasarText.t(
        context,
        'You already completed this subject.',
        'لقد أكملت هذه المادة بالفعل.',
      );
    }

    if (isUnlocked()) {
      return MasarText.t(
        context,
        'You can now take the completion quiz.',
        'يمكنك الآن التقدم لاختبار الإكمال.',
      );
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
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Could not open resource link',
              'تعذر فتح رابط المورد',
            ),
          ),
        ),
      );
    }
  }

  String _deadlineRemainingText() {
    final item = deadline;
    if (item == null) {
      return MasarText.t(
        context,
        'No learning target set.',
        'لم يتم تحديد هدف تعلم.',
      );
    }
    final remaining = item.targetDate.difference(DateTime.now()).inDays;
    if (remaining >= 0) {
      return MasarText.t(context, '$remaining day(s)', '$remaining يوم');
    }
    return MasarText.t(
      context,
      '${remaining.abs()} day(s) late',
      'متأخر ${remaining.abs()} يوم',
    );
  }

  String _deadlineStatusText() {
    final item = deadline;
    if (item == null) {
      return MasarText.t(context, 'No deadline set', 'لا يوجد موعد نهائي');
    }
    if (item.completedOnTime) {
      return MasarText.t(
        context,
        'Completed on time (+10 bonus)',
        'اكتمل في الوقت المحدد (+10 نقاط)',
      );
    }
    if (item.completedLate) {
      return MasarText.t(
        context,
        'Completed late (+0 bonus)',
        'اكتمل متأخراً (+0 نقاط)',
      );
    }
    if (DateTime.now().isAfter(item.targetDate)) {
      return MasarText.t(context, 'Late', 'متأخر');
    }
    return MasarText.t(context, 'On track', 'على المسار');
  }

  Color _deadlineStatusColor() {
    final item = deadline;
    if (item == null) return Colors.grey;
    if (item.completedOnTime) return Colors.green;
    if (item.completedLate || DateTime.now().isAfter(item.targetDate)) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  Widget _buildDeadlineSection() {
    final target = deadline;
    final t = MasarText.t;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(context, 'Set Learning Target', 'تحديد هدف التعلم'),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(t(context, '1 month', 'شهر واحد')),
                  selected: target?.targetMonths == 1,
                  onSelected: (_) => _setDeadlineMonths(1),
                ),
                ChoiceChip(
                  label: Text(t(context, '2 months', 'شهران')),
                  selected: target?.targetMonths == 2,
                  onSelected: (_) => _setDeadlineMonths(2),
                ),
                ChoiceChip(
                  label: Text(t(context, '3 months', '3 أشهر')),
                  selected: target?.targetMonths == 3,
                  onSelected: (_) => _setDeadlineMonths(3),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${t(context, 'Target:', 'الهدف:')} ${target == null ? '-' : t(context, '${target.targetMonths} month(s)', '${target.targetMonths} شهر')}',
            ),
            const SizedBox(height: 6),
            Text(
              '${t(context, 'Remaining:', 'المتبقي:')} ${_deadlineRemainingText()}',
            ),
            const SizedBox(height: 6),
            Text(
              '${t(context, 'Status:', 'الحالة:')} ${_deadlineStatusText()}',
              style: TextStyle(
                color: _deadlineStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${t(context, 'Deadline bonus:', 'نقاط الموعد:')} ${target?.deadlineBonus ?? 0}',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResourcesSection(Subject subject) {
    final t = MasarText.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                t(context, 'Recommended Resources', 'مصادر مقترحة'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  return Text(
                    t(
                      context,
                      'No resources found.',
                      'لم يتم العثور على مصادر.',
                    ),
                  );
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
    final displayName =
        (isArabic && subject.nameAr != null && subject.nameAr!.isNotEmpty)
        ? subject.nameAr!
        : subject.name;
    final displayDescription =
        (isArabic &&
            subject.descriptionAr != null &&
            subject.descriptionAr!.isNotEmpty)
        ? subject.descriptionAr!
        : subject.description;

    final prereqSubjects = getPrerequisiteSubjects();
    final missingPrereqs = getMissingPrerequisiteSubjects();
    final unlocked = isUnlocked();
    final theme = Theme.of(context);
    final t = MasarText.t;

    return Scaffold(
      appBar: AppBar(title: Text(subject.code)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(getStatusIcon(), color: getStatusColor()),
                      const SizedBox(width: 8),
                      Text(
                        '${t(context, 'Status:', 'الحالة:')} ${getStatusText()}',
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
                          Text(
                            '${t(context, 'Code:', 'الرمز:')} ${subject.code}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${t(context, 'Credits:', 'الساعات:')} ${subject.credits}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${t(context, 'Phase:', 'المرحلة:')} ${subject.phase}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${t(context, 'Specialization:', 'التخصص:')} ${isArabic && subject.specializationAr != null ? subject.specializationAr : subject.specialization}',
                          ),
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
                            '${t(context, 'Status:', 'الحالة:')} ${getStatusText()}',
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
                  _buildDeadlineSection(),
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
                              label: Text(
                                t(context, 'Mark as Completed', 'وضع كمكتمل'),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isCompleted
                                  ? () async {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      final message = t(
                                        context,
                                        '${widget.subject.name} marked as uncompleted.',
                                        'تم إلغاء إكمال ${_localizedSubjectName(widget.subject)}.',
                                      );
                                      await progressService.markUncompleted(
                                        widget.specialization,
                                        widget.subject.code,
                                      );
                                      await deadlineService.resetCompletion(
                                        _deadlineSubjectId,
                                      );

                                      await loadCompletionData();
                                      await loadDeadlineData();

                                      if (!mounted) return;

                                      messenger.showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.undo),
                              label: Text(
                                t(
                                  context,
                                  'Uncomplete Subject',
                                  'إلغاء إكمال المادة',
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isCompleted
                                  ? null
                                  : _showDeveloperSkipDialog,
                              icon: const Icon(Icons.code_rounded),
                              label: Text(
                                t(context, 'Developer Skip', 'تجاوز المطور'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t(context, 'Prerequisites', 'المتطلبات السابقة'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (prereqSubjects.isEmpty)
                    Text(t(context, 'None', 'لا يوجد'))
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: prereqSubjects.map((prereq) {
                            final done = completedSubjects.contains(
                              prereq.code,
                            );
                            final pName = (isArabic && prereq.nameAr != null)
                                ? prereq.nameAr!
                                : prereq.name;
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
                    Text(
                      t(context, 'Missing prerequisites', 'المتطلبات الناقصة'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: missingPrereqs.map((s) {
                            final mName = (isArabic && s.nameAr != null)
                                ? s.nameAr!
                                : s.name;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $mName (${s.code})'),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    t(context, 'Description', 'الوصف'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        displayDescription.trim().isEmpty
                            ? t(
                                context,
                                'No description available yet.',
                                'لا يوجد وصف متاح حالياً.',
                              )
                            : displayDescription,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildResourcesSection(subject),
                  const SizedBox(height: 24),
                  Text(
                    t(context, 'Related Skills', 'المهارات المرتبطة'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: subject.skills.isEmpty
                          ? Text(
                              t(
                                context,
                                'No skills added yet.',
                                'لم تتم إضافة مهارات بعد.',
                              ),
                            )
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
