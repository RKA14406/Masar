import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/subject_model.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/progress_service.dart';
import '../../l10n/app_localizations.dart';

import '../career/career_selection_screen.dart';
import '../subject_details/subject_details_screen.dart';
import 'path_view_controller.dart';

import 'widgets/background_glow.dart';
import 'widgets/final_phase_gate_card.dart';
import 'widgets/path_header.dart';
import 'widgets/phase_section_label.dart';
import 'widgets/selected_subject_panel.dart';
import 'widgets/path_map_view.dart';

class PathViewScreen extends StatefulWidget {
  final String college;
  final String specialization;

  const PathViewScreen({
    super.key,
    required this.college,
    required this.specialization,
  });

  @override
  State<PathViewScreen> createState() => _PathViewScreenState();
}

class _PathViewScreenState extends State<PathViewScreen> {
  late final PathViewController _controller;
  String? _collegeAr;
  String? _specializationAr;

  @override
  void initState() {
    super.initState();
    _controller = PathViewController(
      college: widget.college,
      specialization: widget.specialization,
    );
    _controller.loadPath();
    _loadArNames();
  }

  Future<void> _loadArNames() async {
    final mapping = await Phase0MappingService().mapCollegeAndSpecialization(
      college: widget.college,
      specialization: widget.specialization,
    );
    if (mounted) {
      setState(() {
        _collegeAr = mapping?.collegeTitleAr;
        _specializationAr = mapping?.datasetSpecializationAr;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ───────────────────────── helpers ─────────────────────────

  Future<void> _selectTrack() async {
    await ProgressService().selectTrack(
      widget.college,
      widget.specialization,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.trackSelectedSuccess),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ───────────────────────── handlers ─────────────────────────

  Future<void> _handleNodeTap(Subject subject) async {
    await _controller.openSubject(subject);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetailsScreen(
          subject: subject,
          college: widget.college,
          specialization: widget.specialization,
          allSubjects: _controller.allSubjects,
        ),
      ),
    );

    await _controller.loadPath();
  }

  Future<void> _handleNodeLongPress(Subject subject) async {
    final l10n = AppLocalizations.of(context)!;
    final subjectName = subject.localizedName(context);

    if (_controller.completedSubjects.contains(subject.code)) {
      _showSnackBar(l10n.alreadyCompleted(subjectName));
      return;
    }

    if (_controller.nodeStateFor(subject) == NodeVisualState.locked) {
      final missing = _controller
          .missingPrerequisitesFor(subject)
          .map((s) => s.localizedName(context))
          .join(', ');
      _showSnackBar(l10n.completeFirstMessage(missing));
      return;
    }

    await HapticFeedback.mediumImpact();

    final result = await _controller.attemptCompletionQuiz(
      subject: subject,
      context: context,
    );

    if (result == null) return;

    if (!result.passed) {
      final msg = result.integrityPassed
          ? l10n.quizScoreNeedMore(result.scorePercent.toStringAsFixed(1))
          : l10n.integrityViolation;
      _showSnackBar(msg);
      return;
    }

    await _controller.markCompleted(subject);
    if (mounted) _showSnackBar(l10n.subjectCompleted(subjectName));
  }

  Future<void> _handleFinalPhaseTap() async {
    if (!_controller.phase1And2Completed) {
      _showSnackBar(AppLocalizations.of(context)!.completePhasesFirst);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CareerSelectionScreen(
          college: widget.college,
          specialization: widget.specialization,
          completedSubjects: _controller.completedSubjectsList,
        ),
      ),
    );

    await _controller.loadPath();
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_controller.errorMessage != null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.learningPath),
            ),
            body: Center(child: Text(_controller.errorMessage!)),
          );
        }

        return _buildContent(context);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selected = _controller.selectedSubject;
    final missing = selected == null
        ? const <Subject>[]
        : _controller.missingPrerequisitesFor(selected);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),

      // ✅ FIX: BUTTON MOVED TO BOTTOM
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _selectTrack,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: const Color(0xFF57D6FF),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.chooseTrack,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
              Color(0xFF091321),
              Color(0xFF0D1A2D),
              Color(0xFF06101B)
            ]
                : [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (isDark) const BackgroundGlow(),

              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: PathHeader(
                      college: widget.college,
                      specialization: widget.specialization,
                      collegeAr: _collegeAr,
                      specializationAr: _specializationAr,
                      progress: _controller.progressPercent,
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SelectedSubjectPanel(
                      subject: selected,
                      state: selected == null
                          ? null
                          : _controller.nodeStateFor(selected),
                      missingSubjects: missing,
                      onOpenDetails: selected == null
                          ? null
                          : () => _handleNodeTap(selected),
                    ),
                  ),

                  if (_controller.phase1Subjects.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: PhaseSectionLabel(
                        title: 'Phase 1',
                        subtitle: 'Foundation',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: PathMapView(
                        subjects: _controller.phase1Subjects,
                        selectedSubject: _controller.selectedSubject,
                        getNodeState: _controller.nodeStateFor,
                        onNodeTap: _handleNodeTap,
                        onNodeLongPress: _handleNodeLongPress,
                      ),
                    ),
                  ],

                  if (_controller.phase2Subjects.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: PhaseSectionLabel(
                        title: 'Phase 2',
                        subtitle: 'Specialization',
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: PathMapView(
                        subjects: _controller.phase2Subjects,
                        selectedSubject: _controller.selectedSubject,
                        getNodeState: _controller.nodeStateFor,
                        onNodeTap: _handleNodeTap,
                        onNodeLongPress: _handleNodeLongPress,
                      ),
                    ),
                  ],

                  SliverToBoxAdapter(
                    child: FinalPhaseGateCard(
                      isUnlocked: _controller.phase1And2Completed,
                      onTap: _handleFinalPhaseTap,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),

              Positioned(
                top: 16,
                left: 16,
                child: Builder(
                  builder: (context) => IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: Icon(
                      Icons.menu,
                      color: isDark
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}