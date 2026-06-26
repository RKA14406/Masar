import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/career_storage_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/repositories/subject_repository.dart';
import '../../l10n/masar_text.dart';
import 'ats_score_service.dart';
import 'cv_generation_service.dart';
import 'cv_model.dart';
import 'cv_preview_screen.dart';
import 'cv_storage_service.dart';

class CvBuilderScreen extends StatefulWidget {
  final CvInput? initialInput;

  const CvBuilderScreen({super.key, this.initialInput});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _university = TextEditingController();
  final _degree = TextEditingController();
  final _major = TextEditingController();
  final _specialization = TextEditingController();
  final _gradYear = TextEditingController();
  final _gpa = TextEditingController();
  final _targetRole = TextEditingController();

  final _linkLabel = TextEditingController();
  final _linkUrl = TextEditingController();
  final _technicalSkill = TextEditingController();
  final _softSkill = TextEditingController();
  final _tool = TextEditingController();
  final _achievement = TextEditingController();
  final _competition = TextEditingController();
  final _language = TextEditingController();

  final _projectTitle = TextEditingController();
  final _projectDescription = TextEditingController();
  final _projectTech = TextEditingController();
  final _projectLink = TextEditingController();

  final _experienceTitle = TextEditingController();
  final _experienceOrg = TextEditingController();
  final _experienceDate = TextEditingController();
  final _experienceBullets = TextEditingController();

  final _progressService = ProgressService();
  final _careerStorage = CareerStorageService();
  final _cvStorage = CvStorageService();
  final _generator = const CvGenerationService();
  final _ats = const AtsScoreService();
  final _subjects = SubjectRepository(
    localDataSource: SubjectLocalDataSource(),
  );

  final List<CvLink> _links = [];
  final List<String> _technicalSkills = [];
  final List<String> _softSkills = [];
  final List<String> _tools = [];
  final List<CvProject> _projects = [];
  final List<String> _completedSubjects = [];
  final List<String> _achievements = [];
  final List<String> _competitions = [];
  final List<CvExperience> _experience = [];
  final List<String> _languages = [];
  final List<String> _targetRoleOptions = [];

  bool _loading = true;
  bool _generating = false;
  SavedCv? _savedCv;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _location,
      _university,
      _degree,
      _major,
      _specialization,
      _gradYear,
      _gpa,
      _targetRole,
      _linkLabel,
      _linkUrl,
      _technicalSkill,
      _softSkill,
      _tool,
      _achievement,
      _competition,
      _language,
      _projectTitle,
      _projectDescription,
      _projectTech,
      _projectLink,
      _experienceTitle,
      _experienceOrg,
      _experienceDate,
      _experienceBullets,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final saved = await _cvStorage.loadCv();
    final input = widget.initialInput ?? saved?.input;
    if (input != null) {
      _applyInput(input);
      setState(() {
        _savedCv = saved;
        _loading = false;
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final profile = await UserProfileService().getCurrentUserProfile();
    final track = await _progressService.getSelectedTrack();

    _name.text = (profile?['username'] ?? user?.displayName ?? '').toString();
    _email.text = user?.email ?? (profile?['email'] ?? '').toString();

    if (track != null) {
      _major.text = track.college;
      _specialization.text = track.specialization;

      final allSubjects = await _subjects.getSubjectsByCollegeAndSpecialization(
        college: track.college,
        specialization: track.specialization,
      );
      final completedCodes = await _progressService.getCompletedSubjects(
        track.specialization,
      );
      final completed = allSubjects
          .where((subject) => completedCodes.contains(subject.code))
          .toList();

      _completedSubjects.addAll(
        completed.map((subject) => '${subject.code} - ${subject.name}'),
      );
      _technicalSkills.addAll(
        completed
            .expand((subject) => subject.skills)
            .where((skill) => skill.trim().isNotEmpty)
            .toSet()
            .take(20),
      );

      final selectedJobs = await _careerStorage.loadSelectedJobs(
        college: track.college,
        specialization: track.specialization,
      );
      _targetRoleOptions.addAll(selectedJobs.map((job) => job.title));
      if (_targetRoleOptions.isNotEmpty) {
        _targetRole.text = _targetRoleOptions.first;
      }
    }

    setState(() {
      _savedCv = saved;
      _loading = false;
    });
  }

  void _applyInput(CvInput input) {
    _name.text = input.fullName;
    _email.text = input.email;
    _phone.text = input.phone;
    _location.text = input.location;
    _university.text = input.education.institution;
    _degree.text = input.education.degree;
    _major.text = input.education.major;
    _specialization.text = input.education.specialization;
    _gradYear.text = input.education.graduationYear;
    _gpa.text = input.education.gpa;
    _targetRole.text = input.targetRole;
    _links.addAll(input.links);
    _technicalSkills.addAll(input.technicalSkills);
    _softSkills.addAll(input.softSkills);
    _tools.addAll(input.tools);
    _projects.addAll(input.projects);
    _completedSubjects.addAll(input.completedSubjects);
    _achievements.addAll(input.achievements);
    _competitions.addAll(input.competitions);
    _experience.addAll(input.experience);
    _languages.addAll(input.languages);
  }

  CvInput _buildInput() {
    return CvInput(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
      links: List.unmodifiable(_links),
      education: CvEducation(
        institution: _university.text.trim(),
        degree: _degree.text.trim(),
        major: _major.text.trim(),
        specialization: _specialization.text.trim(),
        graduationYear: _gradYear.text.trim(),
        gpa: _gpa.text.trim(),
      ),
      targetRole: _targetRole.text.trim(),
      technicalSkills: List.unmodifiable(_technicalSkills),
      softSkills: List.unmodifiable(_softSkills),
      tools: List.unmodifiable(_tools),
      projects: List.unmodifiable(_projects),
      completedSubjects: List.unmodifiable(_completedSubjects),
      achievements: List.unmodifiable(_achievements),
      competitions: List.unmodifiable(_competitions),
      experience: List.unmodifiable(_experience),
      languages: List.unmodifiable(_languages),
    );
  }

  Future<void> _generateCv() async {
    final input = _buildInput();
    final validation = _validate(input);
    if (validation != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }

    setState(() => _generating = true);

    GeneratedCv cv;
    var usedFallback = false;
    try {
      cv = await _generator.generateWithGemini(input);
    } catch (_) {
      cv = _generator.generateFallback(input);
      usedFallback = true;
    }

    final ats = _ats.evaluate(input, cv);
    final saved = SavedCv(
      input: input,
      cv: cv,
      atsScore: ats.score,
      improvementTips: ats.tips,
      lastUpdated: DateTime.now(),
    );
    await _cvStorage.saveCv(saved);

    if (!mounted) return;
    setState(() => _generating = false);

    if (usedFallback) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Gemini was slow, so Masar generated a local ATS-friendly CV.',
              'كان Gemini بطيئاً، لذلك أنشأ مسار سيرة ذاتية محلية مناسبة لـ ATS.',
            ),
          ),
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CvPreviewScreen(savedCv: saved, usedFallback: usedFallback),
      ),
    );
  }

  String? _validate(CvInput input) {
    if (input.fullName.trim().isEmpty) {
      return MasarText.t(
        context,
        'Add your full name before generating.',
        'أضف اسمك الكامل قبل الإنشاء.',
      );
    }
    if (input.targetRole.trim().isEmpty) {
      return MasarText.t(
        context,
        'Add a target role before generating.',
        'أضف الدور المستهدف قبل الإنشاء.',
      );
    }
    final hasEducation =
        input.education.major.trim().isNotEmpty ||
        input.education.specialization.trim().isNotEmpty ||
        input.education.degree.trim().isNotEmpty;
    if (!hasEducation) {
      return MasarText.t(
        context,
        'Add your education or major before generating.',
        'أضف تعليمك أو تخصصك قبل الإنشاء.',
      );
    }
    if (input.totalSkills < 3) {
      return MasarText.t(
        context,
        'Add at least 3 skills before generating.',
        'أضف 3 مهارات على الأقل قبل الإنشاء.',
      );
    }
    return null;
  }

  void _addString(TextEditingController controller, List<String> list) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    setState(() {
      list.add(value);
      controller.clear();
    });
  }

  void _addLink() {
    if (_linkLabel.text.trim().isEmpty || _linkUrl.text.trim().isEmpty) return;
    setState(() {
      _links.add(
        CvLink(label: _linkLabel.text.trim(), url: _linkUrl.text.trim()),
      );
      _linkLabel.clear();
      _linkUrl.clear();
    });
  }

  void _addProject() {
    if (_projectTitle.text.trim().isEmpty) return;
    setState(() {
      _projects.add(
        CvProject(
          title: _projectTitle.text.trim(),
          description: _projectDescription.text.trim(),
          technologies: _projectTech.text
              .split(',')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
          link: _projectLink.text.trim(),
        ),
      );
      _projectTitle.clear();
      _projectDescription.clear();
      _projectTech.clear();
      _projectLink.clear();
    });
  }

  void _addExperience() {
    if (_experienceTitle.text.trim().isEmpty &&
        _experienceOrg.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _experience.add(
        CvExperience(
          title: _experienceTitle.text.trim(),
          organization: _experienceOrg.text.trim(),
          date: _experienceDate.text.trim(),
          bullets: _experienceBullets.text
              .split('\n')
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
        ),
      );
      _experienceTitle.clear();
      _experienceOrg.clear();
      _experienceDate.clear();
      _experienceBullets.clear();
    });
  }

  void _openSavedCv() {
    final saved = _savedCv;
    if (saved == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CvPreviewScreen(savedCv: saved)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(t(context, 'CV Builder', 'منشئ السيرة الذاتية')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    if (_savedCv != null) ...[
                      OutlinedButton.icon(
                        onPressed: _openSavedCv,
                        icon: const Icon(Icons.description_outlined),
                        label: Text(
                          t(context, 'Open Saved CV', 'فتح السيرة المحفوظة'),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _TipsCard(tips: _builderTips(context)),
                    _Section(
                      title: t(context, 'Personal Info', 'المعلومات الشخصية'),
                      children: [
                        _Field(_name, t(context, 'Full name', 'الاسم الكامل')),
                        _Field(
                          _email,
                          t(context, 'Email', 'البريد الإلكتروني'),
                        ),
                        _Field(_phone, t(context, 'Phone', 'رقم الهاتف')),
                        _Field(
                          _location,
                          t(context, 'City/Country', 'المدينة/الدولة'),
                        ),
                        _LinkEditor(
                          labelController: _linkLabel,
                          urlController: _linkUrl,
                          links: _links,
                          onAdd: _addLink,
                          onRemove: (link) =>
                              setState(() => _links.remove(link)),
                        ),
                      ],
                    ),
                    _Section(
                      title: t(context, 'Education', 'التعليم'),
                      children: [
                        _Field(
                          _university,
                          t(context, 'University', 'الجامعة'),
                        ),
                        _Field(_degree, t(context, 'Degree', 'الدرجة العلمية')),
                        _Field(
                          _major,
                          t(context, 'Degree/major', 'الدرجة/التخصص'),
                        ),
                        _Field(
                          _specialization,
                          t(context, 'Specialization', 'المسار التخصصي'),
                        ),
                        _Field(
                          _gradYear,
                          t(
                            context,
                            'Expected graduation year',
                            'سنة التخرج المتوقعة',
                          ),
                        ),
                        _Field(
                          _gpa,
                          t(context, 'GPA optional', 'المعدل اختياري'),
                        ),
                      ],
                    ),
                    _Section(
                      title: t(context, 'Target Role', 'الدور المستهدف'),
                      children: [
                        if (_targetRoleOptions.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: _targetRoleOptions
                                .map(
                                  (role) => ActionChip(
                                    label: Text(role),
                                    onPressed: () =>
                                        setState(() => _targetRole.text = role),
                                  ),
                                )
                                .toList(),
                          ),
                        _Field(
                          _targetRole,
                          t(
                            context,
                            'Example: Flutter Developer Intern',
                            'مثال: متدرب مطور Flutter',
                          ),
                        ),
                      ],
                    ),
                    _StringEditor(
                      title: t(context, 'Technical Skills', 'المهارات التقنية'),
                      controller: _technicalSkill,
                      values: _technicalSkills,
                      onAdd: () =>
                          _addString(_technicalSkill, _technicalSkills),
                      onRemove: (value) =>
                          setState(() => _technicalSkills.remove(value)),
                    ),
                    _StringEditor(
                      title: t(context, 'Soft Skills', 'المهارات الشخصية'),
                      controller: _softSkill,
                      values: _softSkills,
                      onAdd: () => _addString(_softSkill, _softSkills),
                      onRemove: (value) =>
                          setState(() => _softSkills.remove(value)),
                    ),
                    _StringEditor(
                      title: t(
                        context,
                        'Tools / Languages',
                        'الأدوات / اللغات',
                      ),
                      controller: _tool,
                      values: _tools,
                      onAdd: () => _addString(_tool, _tools),
                      onRemove: (value) => setState(() => _tools.remove(value)),
                    ),
                    _ProjectsEditor(
                      titleController: _projectTitle,
                      descriptionController: _projectDescription,
                      techController: _projectTech,
                      linkController: _projectLink,
                      projects: _projects,
                      onAdd: _addProject,
                      onRemove: (project) =>
                          setState(() => _projects.remove(project)),
                    ),
                    _StringEditor(
                      title: t(context, 'Achievements', 'الإنجازات'),
                      controller: _achievement,
                      values: _achievements,
                      onAdd: () => _addString(_achievement, _achievements),
                      onRemove: (value) =>
                          setState(() => _achievements.remove(value)),
                    ),
                    _StringEditor(
                      title: t(context, 'Competitions', 'المسابقات'),
                      controller: _competition,
                      values: _competitions,
                      onAdd: () => _addString(_competition, _competitions),
                      onRemove: (value) =>
                          setState(() => _competitions.remove(value)),
                    ),
                    _ExperienceEditor(
                      titleController: _experienceTitle,
                      orgController: _experienceOrg,
                      dateController: _experienceDate,
                      bulletsController: _experienceBullets,
                      experience: _experience,
                      onAdd: _addExperience,
                      onRemove: (item) =>
                          setState(() => _experience.remove(item)),
                    ),
                    _StringEditor(
                      title: t(context, 'Languages', 'اللغات'),
                      controller: _language,
                      values: _languages,
                      onAdd: () => _addString(_language, _languages),
                      onRemove: (value) =>
                          setState(() => _languages.remove(value)),
                    ),
                    _ReadonlySection(
                      title: t(
                        context,
                        'Academic Progress from Masar',
                        'التقدم الأكاديمي من مسار',
                      ),
                      values: _completedSubjects,
                    ),
                  ],
                ),
                if (_generating)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                t(
                                  context,
                                  'Generating your ATS-friendly CV...',
                                  'جارٍ إنشاء سيرة ذاتية مناسبة لـ ATS...',
                                ),
                              ),
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
            onPressed: _generating ? null : _generateCv,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: Text(t(context, 'Generate CV', 'إنشاء السيرة الذاتية')),
          ),
        ),
      ),
    );
  }

  List<String> _builderTips(BuildContext context) {
    final tips = <String>[];
    final t = MasarText.t;
    if (_projects.isEmpty) {
      tips.add(
        t(
          context,
          'Add at least one project.',
          'أضف مشروعاً واحداً على الأقل.',
        ),
      );
    }
    if (_technicalSkills.length + _tools.length < 5) {
      tips.add(
        t(
          context,
          'Add more technical skills or tools for ATS matching.',
          'أضف مهارات تقنية أو أدوات أكثر لتحسين مطابقة ATS.',
        ),
      );
    }
    if (!_links.any(
      (link) =>
          link.label.toLowerCase().contains('github') ||
          link.label.toLowerCase().contains('linkedin'),
    )) {
      tips.add(
        t(
          context,
          'Add GitHub or LinkedIn link.',
          'أضف رابط GitHub أو LinkedIn.',
        ),
      );
    }
    if (_completedSubjects.isEmpty) {
      tips.add(
        t(
          context,
          'Add completed subjects from Masar when available.',
          'أضف المواد المكتملة من مسار عند توفرها.',
        ),
      );
    }
    return tips;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

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
            ...children.expand((child) => [child, const SizedBox(height: 10)]),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _Field(this.controller, this.label, {this.maxLines = 1});

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

class _TipsCard extends StatelessWidget {
  final List<String> tips;

  const _TipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();
    final t = MasarText.t;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t(context, 'Before generating', 'قبل الإنشاء'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...tips.map((tip) => Text('- $tip')),
          ],
        ),
      ),
    );
  }
}

class _StringEditor extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final List<String> values;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _StringEditor({
    required this.title,
    required this.controller,
    required this.values,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return _Section(
      title: title,
      children: [
        Row(
          children: [
            Expanded(
              child: _Field(controller, t(context, 'Add item', 'أضف عنصراً')),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: onAdd, icon: const Icon(Icons.add)),
          ],
        ),
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
    );
  }
}

class _LinkEditor extends StatelessWidget {
  final TextEditingController labelController;
  final TextEditingController urlController;
  final List<CvLink> links;
  final VoidCallback onAdd;
  final ValueChanged<CvLink> onRemove;

  const _LinkEditor({
    required this.labelController,
    required this.urlController,
    required this.links,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return Column(
      children: [
        _Field(
          labelController,
          t(context, 'Link label, e.g. LinkedIn', 'اسم الرابط، مثل LinkedIn'),
        ),
        _Field(urlController, t(context, 'URL', 'الرابط')),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_link),
            label: Text(t(context, 'Add Link', 'إضافة رابط')),
          ),
        ),
        ...links.map(
          (link) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(link.label),
            subtitle: Text(link.url),
            trailing: IconButton(
              onPressed: () => onRemove(link),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectsEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController techController;
  final TextEditingController linkController;
  final List<CvProject> projects;
  final VoidCallback onAdd;
  final ValueChanged<CvProject> onRemove;

  const _ProjectsEditor({
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
    final t = MasarText.t;
    return _Section(
      title: t(context, 'Projects', 'المشاريع'),
      children: [
        _Field(titleController, t(context, 'Project title', 'عنوان المشروع')),
        _Field(
          descriptionController,
          t(context, 'Description', 'الوصف'),
          maxLines: 3,
        ),
        _Field(
          techController,
          t(
            context,
            'Technologies used, separated by commas',
            'التقنيات المستخدمة، مفصولة بفواصل',
          ),
        ),
        _Field(
          linkController,
          t(context, 'Optional project link', 'رابط المشروع اختياري'),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(t(context, 'Add Project', 'إضافة مشروع')),
          ),
        ),
        ...projects.map(
          (project) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(project.title),
            subtitle: Text(project.description),
            trailing: IconButton(
              onPressed: () => onRemove(project),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExperienceEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController orgController;
  final TextEditingController dateController;
  final TextEditingController bulletsController;
  final List<CvExperience> experience;
  final VoidCallback onAdd;
  final ValueChanged<CvExperience> onRemove;

  const _ExperienceEditor({
    required this.titleController,
    required this.orgController,
    required this.dateController,
    required this.bulletsController,
    required this.experience,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return _Section(
      title: t(context, 'Experience', 'الخبرة'),
      children: [
        _Field(titleController, t(context, 'Title optional', 'المسمى اختياري')),
        _Field(
          orgController,
          t(context, 'Organization optional', 'الجهة اختيارية'),
        ),
        _Field(dateController, t(context, 'Date optional', 'التاريخ اختياري')),
        _Field(
          bulletsController,
          t(context, 'Bullets, one per line', 'النقاط، كل نقطة في سطر'),
          maxLines: 3,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text(t(context, 'Add Experience', 'إضافة خبرة')),
          ),
        ),
        ...experience.map(
          (item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              [
                item.title,
                item.organization,
              ].where((part) => part.isNotEmpty).join(' - '),
            ),
            subtitle: Text(item.date),
            trailing: IconButton(
              onPressed: () => onRemove(item),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadonlySection extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ReadonlySection({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    return _Section(
      title: title,
      children: values.isEmpty
          ? [
              Text(
                t(
                  context,
                  'Completed subjects will appear here when available.',
                  'ستظهر المواد المكتملة هنا عند توفرها.',
                ),
              ),
            ]
          : values.take(12).map((value) => Text('- $value')).toList(),
    );
  }
}
