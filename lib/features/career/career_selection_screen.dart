import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/career_llm_service.dart';
import '../../core/services/career_storage_service.dart';
import '../../data/models/subject_model.dart';
import '../../core/widgets/app_drawer.dart';
import 'job_selection_screen.dart';
import 'phase3_path_screen.dart';

class CareerSelectionScreen extends StatefulWidget {
  final String college;
  final String specialization;
  final List<Subject> completedSubjects;

  const CareerSelectionScreen({
    super.key,
    required this.college,
    required this.specialization,
    required this.completedSubjects,
  });

  @override
  State<CareerSelectionScreen> createState() => _CareerSelectionScreenState();
}

class _CareerSelectionScreenState extends State<CareerSelectionScreen> {
  final CareerLlmService _careerLlmService = CareerLlmService();
  final CareerStorageService _careerStorageService = CareerStorageService();

  bool _isLoading = false;

  Future<void> _startFinalPhase() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';

    final alreadyGenerated = await _careerStorageService.isPhase3Generated(
      college: widget.college,
      specialization: widget.specialization,
    );

    if (alreadyGenerated) {
      if (!mounted) return;
      Navigator.push(
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
      _isLoading = true;
    });

    try {
      final jobs = await _careerLlmService.suggestJobs(
        college: widget.college,
        specialization: widget.specialization,
        completedSubjects: widget.completedSubjects,
        language: language,
      );

      await _careerStorageService.saveSuggestedJobs(
        college: widget.college,
        specialization: widget.specialization,
        jobs: jobs,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobSelectionScreen(
            college: widget.college,
            specialization: widget.specialization,
            completedSubjects: widget.completedSubjects,
            suggestedJobs: jobs,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.career_error_loading_jobs(error.toString())),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
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
        title: Text(l10n.career_phase3_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.workspace_premium, size: 78),
            const SizedBox(height: 20),
            Text(
              l10n.career_phase3_header,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.career_phase3_description(
                widget.specialization,
                widget.college,
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.career_phase3_what_next,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.career_phase3_step1),
                    const SizedBox(height: 8),
                    Text(l10n.career_phase3_step2),
                    const SizedBox(height: 8),
                    Text(l10n.career_phase3_step3),
                    const SizedBox(height: 8),
                    Text(l10n.career_phase3_step4),
                    const SizedBox(height: 8),
                    Text(l10n.career_phase3_step5),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 62,
              child: FilledButton(
                onPressed: _isLoading ? null : _startFinalPhase,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                  l10n.career_phase3_button,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
