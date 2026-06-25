import 'package:flutter/material.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../path_view/path_view_screen.dart';

class SpecialtyRecommendationScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Phase0SpecialtyRecommendation> recommendations;
  final String? emptyMessage;

  const SpecialtyRecommendationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.recommendations,
    this.emptyMessage,
  });

  @override
  State<SpecialtyRecommendationScreen> createState() =>
      _SpecialtyRecommendationScreenState();
}

class _SpecialtyRecommendationScreenState
    extends State<SpecialtyRecommendationScreen> {
  final Phase0MappingService _mappingService = Phase0MappingService();
  final Map<String, Phase0MappedSpecialty> _mappingCache = {};
  final Set<String> _openingKeys = {};

  @override
  void initState() {
    super.initState();
    _primeMappings();
  }

  Future<void> _primeMappings() async {
    final futures = widget.recommendations.map((recommendation) async {
      final mapping =
      await _mappingService.mapSpecialtyKey(recommendation.specialtyKey);
      return MapEntry(recommendation.specialtyKey, mapping);
    });

    final results = await Future.wait(futures);

    for (final entry in results) {
      if (entry.value != null) {
        _mappingCache[entry.key] = entry.value!;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openTree(Phase0SpecialtyRecommendation recommendation) async {
    final key = recommendation.specialtyKey;
    if (_openingKeys.contains(key)) return;

    setState(() => _openingKeys.add(key));

    try {
      final mapping = await _mappingService.requireMapping(key);

      await ProgressService().selectTrack(
        mapping.collegeTitle,
        mapping.datasetSpecialization,
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PathViewScreen(
            college: mapping.collegeTitle,
            specialization: mapping.datasetSpecialization,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Open tree error: $error');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.specialtyOpenError),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingKeys.remove(key));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.specialtyTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: widget.recommendations.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.emptyMessage ?? l10n.specialtyEmpty,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: widget.recommendations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = widget.recommendations[index];
                  return _RecommendationCard(
                    recommendation: item,
                    mapping: _mappingCache[item.specialtyKey],
                    isBusy: _openingKeys.contains(item.specialtyKey),
                    onTap: () => _openTree(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Phase0SpecialtyRecommendation recommendation;
  final Phase0MappedSpecialty? mapping;
  final bool isBusy;
  final VoidCallback onTap;

  const _RecommendationCard({
    required this.recommendation,
    required this.mapping,
    required this.isBusy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = theme.brightness == Brightness.dark;
    final percent = (recommendation.confidence * 100).round();

    final displayTitle = isArabic
        ? (mapping?.datasetSpecializationAr ??
        mapping?.datasetSpecialization ??
        recommendation.title)
        : (mapping?.datasetSpecialization ?? recommendation.title);

    final displayCollege = isArabic
        ? (mapping?.collegeTitleAr ?? mapping?.collegeTitle ?? '')
        : (mapping?.collegeTitle ?? '');

    final sectionTitle = isArabic ? 'المسارات الوظيفية المتوقعة' : 'Top career roles';
    final salaryTitle = isArabic ? 'متوسط الرواتب' : 'Average salary';
    final jordanLabel = isArabic ? 'الأردن' : 'Jordan';
    final gulfLabel = isArabic ? 'الخليج' : 'Gulf';
    final worldLabel = isArabic ? 'عالميًا' : 'Worldwide';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.cardColor,
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$percent%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (mapping != null && displayCollege.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${l10n.collegeLabel}: $displayCollege',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                recommendation.shortDescription,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                recommendation.fitReason,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (recommendation.jobs.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  sectionTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...recommendation.jobs.map(
                      (job) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _JobInsightCard(
                      job: job,
                      salaryTitle: salaryTitle,
                      jordanLabel: jordanLabel,
                      gulfLabel: gulfLabel,
                      worldLabel: worldLabel,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                  onPressed: isBusy ? null : onTap,
                  child: isBusy
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(l10n.openTree),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobInsightCard extends StatelessWidget {
  final Phase0JobInsight job;
  final String salaryTitle;
  final String jordanLabel;
  final String gulfLabel;
  final String worldLabel;

  const _JobInsightCard({
    required this.job,
    required this.salaryTitle,
    required this.jordanLabel,
    required this.gulfLabel,
    required this.worldLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            salaryTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _SalaryLine(label: jordanLabel, value: job.averageSalary.jordan),
          const SizedBox(height: 4),
          _SalaryLine(label: gulfLabel, value: job.averageSalary.gulf),
          const SizedBox(height: 4),
          _SalaryLine(label: worldLabel, value: job.averageSalary.worldwide),
        ],
      ),
    );
  }
}

class _SalaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SalaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}