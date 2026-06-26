import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/career_storage_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';
import 'portfolio_generation_service.dart';
import 'portfolio_model.dart';
import 'portfolio_preview_screen.dart';
import 'portfolio_storage_service.dart';

class PortfolioInputScreen extends StatefulWidget {
  final PortfolioInput? initialInput;

  const PortfolioInputScreen({super.key, this.initialInput});

  @override
  State<PortfolioInputScreen> createState() => _PortfolioInputScreenState();
}

class _PortfolioInputScreenState extends State<PortfolioInputScreen> {
  final _fullNameController = TextEditingController();
  final _majorController = TextEditingController();
  final _goalController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillController = TextEditingController();
  final _achievementController = TextEditingController();
  final _competitionController = TextEditingController();

  final _projectTitleController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _projectTechController = TextEditingController();
  final _projectLinkController = TextEditingController();

  final _linkLabelController = TextEditingController();
  final _linkUrlController = TextEditingController();

  final _progressService = ProgressService();
  final _careerStorageService = CareerStorageService();
  final _storageService = PortfolioStorageService();
  final _generationService = const PortfolioGenerationService();
  final _subjectRepository = SubjectRepository(
    localDataSource: SubjectLocalDataSource(),
  );

  final List<String> _skills = [];
  final List<String> _achievements = [];
  final List<String> _competitions = [];
  final List<PortfolioProjectInput> _projects = [];
  final List<PortfolioLink> _links = [];
  final List<String> _completedSubjects = [];
  final List<String> _targetRoles = [];

  String _learningProgress = '';
  SavedPortfolio? _savedPortfolio;
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _majorController.addListener(_refreshGuidance);
    _loadInitialData();
  }

  @override
  void dispose() {
    _majorController.removeListener(_refreshGuidance);
    _fullNameController.dispose();
    _majorController.dispose();
    _goalController.dispose();
    _summaryController.dispose();
    _skillController.dispose();
    _achievementController.dispose();
    _competitionController.dispose();
    _projectTitleController.dispose();
    _projectDescriptionController.dispose();
    _projectTechController.dispose();
    _projectLinkController.dispose();
    _linkLabelController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  void _refreshGuidance() {
    if (mounted) setState(() {});
  }

  Future<void> _loadInitialData() async {
    final saved = await _storageService.loadPortfolio();
    final input = widget.initialInput ?? saved?.input;

    if (input != null) {
      _applyInput(input);
      setState(() {
        _savedPortfolio = saved;
        _isLoading = false;
      });
      return;
    }

    final profile = await UserProfileService().getCurrentUserProfile();
    final user = FirebaseAuth.instance.currentUser;
    final track = await _progressService.getSelectedTrack();

    List<Subject> subjects = [];
    Set<String> completedCodes = {};

    if (track != null) {
      subjects = await _subjectRepository.getSubjectsByCollegeAndSpecialization(
        college: track.college,
        specialization: track.specialization,
      );
      completedCodes = await _progressService.getCompletedSubjects(
        track.specialization,
      );

      final completed = subjects
          .where((subject) => completedCodes.contains(subject.code))
          .toList(growable: false);

      _completedSubjects
        ..clear()
        ..addAll(
          completed.map((subject) => '${subject.code} - ${subject.name}'),
        );

      _skills
        ..clear()
        ..addAll(
          completed
              .expand((subject) => subject.skills)
              .where((skill) => skill.trim().isNotEmpty)
              .toSet()
              .take(16),
        );

      final phaseSubjects = subjects.where(
        (subject) => subject.phase == 1 || subject.phase == 2,
      );
      final total = phaseSubjects.length;
      final done = phaseSubjects
          .where((subject) => completedCodes.contains(subject.code))
          .length;
      _learningProgress = total == 0
          ? ''
          : 'Learning Progress: $done of $total phase 1 and phase 2 subjects completed.';

      final selectedJobs = await _careerStorageService.loadSelectedJobs(
        college: track.college,
        specialization: track.specialization,
      );
      _targetRoles
        ..clear()
        ..addAll(selectedJobs.map((job) => job.title));

      _majorController.text = track.specialization;
    }

    _fullNameController.text = (profile?['username'] ?? user?.displayName ?? '')
        .toString();
    _goalController.text = _targetRoles.isNotEmpty ? _targetRoles.first : '';

    setState(() {
      _savedPortfolio = saved;
      _isLoading = false;
    });
  }

  void _applyInput(PortfolioInput input) {
    _fullNameController.text = input.fullName;
    _majorController.text = input.major;
    _goalController.text = input.goalTitle;
    _summaryController.text = input.manualSummary;
    _skills
      ..clear()
      ..addAll(input.skills);
    _projects
      ..clear()
      ..addAll(input.projects);
    _achievements
      ..clear()
      ..addAll(input.achievements);
    _competitions
      ..clear()
      ..addAll(input.competitions);
    _links
      ..clear()
      ..addAll(input.links);
    _completedSubjects
      ..clear()
      ..addAll(input.completedSubjects);
    _targetRoles
      ..clear()
      ..addAll(input.targetRoles);
    _learningProgress = input.learningProgress;
  }

  PortfolioInput _buildInput() {
    return PortfolioInput(
      fullName: _fullNameController.text.trim(),
      major: _majorController.text.trim(),
      goalTitle: _goalController.text.trim(),
      manualSummary: _summaryController.text.trim(),
      skills: List<String>.unmodifiable(_skills),
      projects: List<PortfolioProjectInput>.unmodifiable(_projects),
      achievements: List<String>.unmodifiable(_achievements),
      competitions: List<String>.unmodifiable(_competitions),
      links: List<PortfolioLink>.unmodifiable(_links),
      completedSubjects: List<String>.unmodifiable(_completedSubjects),
      learningProgress: _learningProgress,
      targetRoles: List<String>.unmodifiable(_targetRoles),
    );
  }

  void _addStringItem(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  void _removeStringItem(List<String> target, String value) {
    setState(() {
      target.remove(value);
    });
  }

  void _addProject() {
    final title = _projectTitleController.text.trim();
    final description = _projectDescriptionController.text.trim();
    final link = _projectLinkController.text.trim();
    final technologies = _projectTechController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (title.isEmpty) return;

    setState(() {
      _projects.add(
        PortfolioProjectInput(
          title: title,
          description: description,
          technologies: technologies,
          link: link,
        ),
      );
      _projectTitleController.clear();
      _projectDescriptionController.clear();
      _projectTechController.clear();
      _projectLinkController.clear();
    });
  }

  void _addLink() {
    final label = _linkLabelController.text.trim();
    final url = _linkUrlController.text.trim();
    if (label.isEmpty || url.isEmpty) return;

    setState(() {
      _links.add(PortfolioLink(label: label, url: url));
      _linkLabelController.clear();
      _linkUrlController.clear();
    });
  }

  Future<void> _generatePortfolio() async {
    final input = _buildInput();
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';

    setState(() {
      _isGenerating = true;
    });

    GeneratedPortfolio portfolio;
    var usedFallback = false;

    try {
      portfolio = await _generationService.generateWithGemini(
        input: input,
        language: language,
      );
    } catch (error) {
      portfolio = _generationService.generateFallback(input);
      usedFallback = true;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gemini could not generate right now. A local draft was created and you can retry.',
            ),
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PortfolioPreviewScreen(
          portfolio: SavedPortfolio(
            input: input,
            portfolio: portfolio,
            lastUpdated: DateTime.now(),
          ),
          usedFallback: usedFallback,
        ),
      ),
    );
  }

  void _openSavedPortfolio() {
    final saved = _savedPortfolio;
    if (saved == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PortfolioPreviewScreen(portfolio: saved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final missingTips = _missingDataTips();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Create Your Portfolio')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (missingTips.isNotEmpty)
                      _GuidanceCard(messages: missingTips),
                    if (_savedPortfolio != null) ...[
                      OutlinedButton.icon(
                        onPressed: _openSavedPortfolio,
                        icon: const Icon(Icons.folder_open_outlined),
                        label: const Text('Open Saved Portfolio'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _SectionCard(
                      title: 'Detected Profile Data',
                      child: Column(
                        children: [
                          _PortfolioTextField(
                            controller: _fullNameController,
                            label: 'Full name',
                          ),
                          const SizedBox(height: 12),
                          _PortfolioTextField(
                            controller: _majorController,
                            label: 'Major',
                          ),
                          const SizedBox(height: 12),
                          _PortfolioTextField(
                            controller: _goalController,
                            label: 'Short goal or title',
                          ),
                          const SizedBox(height: 12),
                          _PortfolioTextField(
                            controller: _summaryController,
                            label: 'Professional summary',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    _StringEntrySection(
                      title: 'Skills',
                      hint: 'Add a skill',
                      controller: _skillController,
                      values: _skills,
                      onAdd: () => _addStringItem(_skillController, _skills),
                      onRemove: (value) => _removeStringItem(_skills, value),
                    ),
                    _ProjectSection(
                      titleController: _projectTitleController,
                      descriptionController: _projectDescriptionController,
                      techController: _projectTechController,
                      linkController: _projectLinkController,
                      projects: _projects,
                      onAdd: _addProject,
                      onRemove: (project) {
                        setState(() {
                          _projects.remove(project);
                        });
                      },
                    ),
                    _StringEntrySection(
                      title: 'Achievements',
                      hint: 'Add an achievement',
                      controller: _achievementController,
                      values: _achievements,
                      onAdd: () =>
                          _addStringItem(_achievementController, _achievements),
                      onRemove: (value) =>
                          _removeStringItem(_achievements, value),
                    ),
                    _StringEntrySection(
                      title: 'Competitions',
                      hint: 'Add competition experience',
                      controller: _competitionController,
                      values: _competitions,
                      onAdd: () =>
                          _addStringItem(_competitionController, _competitions),
                      onRemove: (value) =>
                          _removeStringItem(_competitions, value),
                    ),
                    _LinksSection(
                      labelController: _linkLabelController,
                      urlController: _linkUrlController,
                      links: _links,
                      onAdd: _addLink,
                      onRemove: (link) {
                        setState(() {
                          _links.remove(link);
                        });
                      },
                    ),
                    _ReadonlyListSection(
                      title: 'Completed Subjects',
                      values: _completedSubjects,
                      emptyText: 'Completed subjects will appear here.',
                    ),
                    _ReadonlyListSection(
                      title: 'Target Career Roles',
                      values: _targetRoles,
                      emptyText: 'Target roles will appear here when selected.',
                    ),
                    if (_learningProgress.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _learningProgress,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    const SizedBox(height: 90),
                  ],
                ),
                if (_isGenerating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Creating your portfolio...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _isLoading || _isGenerating ? null : _generatePortfolio,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Generate Portfolio'),
          ),
        ),
      ),
    );
  }

  List<String> _missingDataTips() {
    final tips = <String>[];
    if (_majorController.text.trim().isEmpty) {
      tips.add('Add your major before exporting.');
    }
    if (_projects.isEmpty) {
      tips.add('Add at least one project to make your portfolio stronger.');
    }
    if (_skills.isEmpty) {
      tips.add('Add skills so the portfolio can show a stronger snapshot.');
    }
    return tips;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  final List<String> messages;

  const _GuidanceCard({required this.messages});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before exporting',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...messages.map(
              (message) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortfolioTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _PortfolioTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _StringEntrySection extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final List<String> values;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _StringEntrySection({
    required this.title,
    required this.hint,
    required this.controller,
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _PortfolioTextField(controller: controller, label: hint),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Add',
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (values.isEmpty)
            Text(
              'No items added yet.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: values
                  .map(
                    (value) => InputChip(
                      label: Text(value),
                      onDeleted: () => onRemove(value),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ProjectSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController techController;
  final TextEditingController linkController;
  final List<PortfolioProjectInput> projects;
  final VoidCallback onAdd;
  final ValueChanged<PortfolioProjectInput> onRemove;

  const _ProjectSection({
    required this.titleController,
    required this.descriptionController,
    required this.techController,
    required this.linkController,
    required this.projects,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Projects',
      child: Column(
        children: [
          _PortfolioTextField(
            controller: titleController,
            label: 'Project title',
          ),
          const SizedBox(height: 10),
          _PortfolioTextField(
            controller: descriptionController,
            label: 'Short description',
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          _PortfolioTextField(
            controller: techController,
            label: 'Technologies, separated by commas',
          ),
          const SizedBox(height: 10),
          _PortfolioTextField(
            controller: linkController,
            label: 'Optional project link',
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Project'),
            ),
          ),
          const SizedBox(height: 10),
          ...projects.map(
            (project) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(project.title),
              subtitle: Text(
                [
                  if (project.description.isNotEmpty) project.description,
                  if (project.technologies.isNotEmpty)
                    project.technologies.join(', '),
                  if (project.link.isNotEmpty) project.link,
                ].join('\n'),
              ),
              trailing: IconButton(
                onPressed: () => onRemove(project),
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinksSection extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController urlController;
  final List<PortfolioLink> links;
  final VoidCallback onAdd;
  final ValueChanged<PortfolioLink> onRemove;

  const _LinksSection({
    required this.labelController,
    required this.urlController,
    required this.links,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Links',
      child: Column(
        children: [
          _PortfolioTextField(
            controller: labelController,
            label: 'Label, e.g. GitHub',
          ),
          const SizedBox(height: 10),
          _PortfolioTextField(controller: urlController, label: 'URL'),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_link),
              label: const Text('Add Link'),
            ),
          ),
          const SizedBox(height: 10),
          ...links.map(
            (link) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(link.label),
              subtitle: Text(link.url),
              trailing: IconButton(
                onPressed: () => onRemove(link),
                icon: const Icon(Icons.close),
                tooltip: 'Remove',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadonlyListSection extends StatelessWidget {
  final String title;
  final List<String> values;
  final String emptyText;

  const _ReadonlyListSection({
    required this.title,
    required this.values,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: values.isEmpty
          ? Text(emptyText)
          : Column(
              children: values
                  .take(10)
                  .map(
                    (value) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(value),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
