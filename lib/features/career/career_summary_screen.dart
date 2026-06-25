import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/career_llm_service.dart';
import '../../core/services/career_storage_service.dart';
import '../../core/services/progress_service.dart';
import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';

class CareerSummaryScreen extends StatefulWidget {
  final String college;
  final String specialization;

  const CareerSummaryScreen({
    super.key,
    required this.college,
    required this.specialization,
  });

  @override
  State<CareerSummaryScreen> createState() => _CareerSummaryScreenState();
}

class _CareerSummaryScreenState extends State<CareerSummaryScreen> {
  final CareerStorageService _careerStorageService = CareerStorageService();
  final ProgressService _progressService = ProgressService();

  late final SubjectRepository _repository;

  List<CareerJobSuggestion> _selectedJobs = [];
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
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      final results = await Future.wait([
        _careerStorageService.loadSelectedJobs(
          college: widget.college,
          specialization: widget.specialization,
        ),
        _careerStorageService.loadGeneratedNodes(
          college: widget.college,
          specialization: widget.specialization,
        ),
        _repository.getSubjectsByCollegeAndSpecialization(
          college: widget.college,
          specialization: widget.specialization,
        ),
        _progressService.getCompletedSubjects(widget.specialization),
      ]);

      setState(() {
        _selectedJobs = results[0] as List<CareerJobSuggestion>;
        _phase3Nodes = results[1] as List<Subject>;
        _baseSubjects = results[2] as List<Subject>;
        _completedCodes = results[3] as Set<String>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  List<Subject> get _completedBaseSubjects => _baseSubjects
      .where((subject) => _completedCodes.contains(subject.code))
      .toList(growable: false);

  List<Subject> get _completedPhase3Nodes => _phase3Nodes
      .where((subject) => _completedCodes.contains(subject.code))
      .toList(growable: false);

  List<String> get _finalSkills {
    final seen = <String>{};
    final output = <String>[];

    for (final subject in [..._completedBaseSubjects, ..._completedPhase3Nodes]) {
      for (final skill in subject.skills) {
        final normalized = skill.trim();
        if (normalized.isEmpty) continue;
        if (seen.add(normalized.toLowerCase())) {
          output.add(normalized);
        }
      }
    }

    return output;
  }

  // ✅ Arabic hardcoded CV text
  String get _cvReadyText {
    final jobs = _selectedJobs.map((job) => job.title).join(', ');
    final coreSkills = _finalSkills.take(12).join(', ');
    final phase3Topics =
    _completedPhase3Nodes.map((node) => node.name).join(', ');

    return 'مرشح جامعي في تخصص ${widget.specialization} (${widget.college}) '
        'أتم المسار الأكاديمي بالكامل، واكتسب جاهزية مهنية تتوافق مع الوظائف التالية: $jobs. '
        'أنجز ${_completedBaseSubjects.length} مادة دراسية، '
        'وعزز مهاراته التطبيقية من خلال مواضيع المرحلة الثالثة مثل: $phase3Topics. '
        'من أبرز مهاراته: $coreSkills.';
  }

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
        appBar: AppBar(title: Text(l10n.careerSummaryTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.careerSummaryTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.careerSelectedJobs,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedJobs.isEmpty)
                      Text(l10n.careerNoJobs)
                    else
                      ..._selectedJobs.map(
                            (job) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(job.title),
                            subtitle: Text(job.shortDescription),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.careerCompletedSubjects,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.careerAcademicCompleted(
                        _completedBaseSubjects.length)),
                    const SizedBox(height: 8),
                    Text(l10n.careerPhase3Completed(
                        _completedPhase3Nodes.length)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.careerFinalSkills,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _finalSkills
                          .map((skill) => Chip(label: Text(skill)))
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.careerCvReady,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _cvReadyText,
                      style: const TextStyle(height: 1.5),
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