import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/career_llm_service.dart';
import '../../core/services/career_phase3_builder.dart';
import '../../core/services/career_storage_service.dart';
import '../../data/models/subject_model.dart';
import '../../core/widgets/app_drawer.dart';
import 'phase3_path_screen.dart';

class JobSelectionScreen extends StatefulWidget {
  final String college;
  final String specialization;
  final List<Subject> completedSubjects;
  final List<CareerJobSuggestion> suggestedJobs;

  const JobSelectionScreen({
    super.key,
    required this.college,
    required this.specialization,
    required this.completedSubjects,
    required this.suggestedJobs,
  });

  @override
  State<JobSelectionScreen> createState() => _JobSelectionScreenState();
}

class _JobSelectionScreenState extends State<JobSelectionScreen> {
  final CareerLlmService _careerLlmService = CareerLlmService();
  final CareerPhase3Builder _builder = const CareerPhase3Builder();
  final CareerStorageService _storageService = CareerStorageService();

  final Set<int> _selectedIndexes = {};
  bool _isGenerating = false;

  List<CareerJobSuggestion> get _selectedJobs => _selectedIndexes
      .map((index) => widget.suggestedJobs[index])
      .toList(growable: false);

  void _toggleSelection(int index) {
    final l10n = AppLocalizations.of(context)!;

    if (_isGenerating) return;

    if (_selectedIndexes.contains(index)) {
      setState(() {
        _selectedIndexes.remove(index);
      });
      return;
    }

    if (_selectedIndexes.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.jobs_max_selection),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndexes.add(index);
    });
  }

  Future<void> _showJobDetails(CareerJobSuggestion job) async {
    final l10n = AppLocalizations.of(context)!;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(job.fullDescription),
            const SizedBox(height: 16),
            Text(
              l10n.jobs_fit_title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(job.fitReason),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePhase3() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';

    if (_selectedJobs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.jobs_select_at_least_one),
        ),
      );
      return;
    }

    final alreadyGenerated = await _storageService.isPhase3Generated(
      college: widget.college,
      specialization: widget.specialization,
    );

    if (alreadyGenerated) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Phase3PathScreen(
            college: widget.college,
            specialization: widget.specialization,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final topics = await _careerLlmService.generatePhase3Topics(
        college: widget.college,
        specialization: widget.specialization,
        completedSubjects: widget.completedSubjects,
        selectedJobs: _selectedJobs,
        language: language,
      );

      final nodes = _builder.buildNodes(
        college: widget.college,
        specialization: widget.specialization,
        topics: topics,
      );

      await _storageService.saveSelectedJobs(
        college: widget.college,
        specialization: widget.specialization,
        jobs: _selectedJobs,
      );
      await _storageService.saveGeneratedNodes(
        college: widget.college,
        specialization: widget.specialization,
        nodes: nodes,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => Phase3PathScreen(
            college: widget.college,
            specialization: widget.specialization,
          ),
        ),
            (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.jobs_generation_failed(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.jobs_screen_title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.jobs_select_title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.jobs_select_subtitle(_selectedJobs.length),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: widget.suggestedJobs.length,
              itemBuilder: (context, index) {
                final job = widget.suggestedJobs[index];
                final isSelected = _selectedIndexes.contains(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _toggleSelection(index),
                    onLongPress: () => _showJobDetails(job),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(job.shortDescription),
                          const SizedBox(height: 10),
                          Text(
                            l10n.jobs_fit_reason(job.fitReason),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isGenerating ? null : _generatePhase3,
                child: _isGenerating
                    ? const CircularProgressIndicator()
                    : Text(l10n.jobs_generate_button),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
