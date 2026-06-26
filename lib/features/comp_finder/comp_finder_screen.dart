import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/theme/app_colors.dart';
import 'models/competition_model.dart';
import 'services/comp_finder_gemini_service.dart';
import 'services/comp_finder_service.dart';

class CompFinderScreen extends StatefulWidget {
  const CompFinderScreen({super.key});

  @override
  State<CompFinderScreen> createState() => _CompFinderScreenState();
}

class _CompFinderScreenState extends State<CompFinderScreen>
    with SingleTickerProviderStateMixin {
  final CompFinderService _service = CompFinderService();
  final CompFinderGeminiService _geminiService =
      const CompFinderGeminiService();

  late TabController _tabController;
  final List<String> _tabs = [
    'All',
    'Saved',
    'Interested',
    'Applied',
    'Completed',
  ];

  List<Competition> _competitions = [];
  bool _isLoading = true;
  bool _isAiLoading = false;
  String _errorMessage = '';
  String _searchQuery = '';

  String _selectedField = 'All';
  String _selectedLocation = 'All';
  String _selectedLevel = 'All';

  final List<String> _fields = [
    'All',
    'AI / Tech',
    'Business',
    'Finance',
    'Design',
    'Marketing',
    'Engineering',
    'Health',
    'Science',
    'Entrepreneurship',
    'Open Innovation',
    'Sustainability',
  ];
  final List<String> _locations = ['All', 'Online', 'In-Person', 'Hybrid'];
  final List<String> _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final results = await _service.getRecommendedCompetitions(
        fieldFilter: _selectedField,
        locationFilter: _selectedLocation,
        levelFilter: _selectedLevel,
      );
      if (mounted) setState(() => _competitions = results);
      // Fire AI enrichment in background — competitions show immediately
      _enrichWithAI();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not load competitions.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _enrichWithAI() async {
    if (!mounted || _competitions.isEmpty) return;
    setState(() => _isAiLoading = true);
    try {
      final track = await ProgressService().getSelectedTrack();
      final college = track?.college ?? '';
      final specialization = track?.specialization ?? '';
      final completedSubjects = specialization.isNotEmpty
          ? (await ProgressService().getCompletedSubjects(
              specialization,
            )).toList()
          : <String>[];
      final profile = await UserProfileService().getCurrentUserProfile();
      final username = profile?['username'] as String? ?? '';
      final age = (profile?['age'] as num?)?.toInt() ?? 0;

      final enriched = await _geminiService.enrichWithAI(
        competitions: _competitions,
        college: college,
        specialization: specialization,
        completedSubjects: completedSubjects,
        username: username,
        age: age,
      );
      enriched.sort((a, b) => b.fitScore.compareTo(a.fitScore));
      if (mounted) setState(() => _competitions = enriched);
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  Future<void> _updateStatus(Competition c, String status) async {
    await _service.updateCompetitionStatus(c.id, status);
    setState(() {
      final idx = _competitions.indexWhere((x) => x.id == c.id);
      if (idx != -1) {
        _competitions[idx] = _competitions[idx].copyWith(savedStatus: status);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Marked as $status'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  List<Competition> get _filteredCompetitions {
    final tab = _tabs[_tabController.index];
    final statusMap = {
      'Saved': 'saved',
      'Interested': 'interested',
      'Applied': 'applied',
      'Completed': 'completed',
    };

    List<Competition> result = _competitions;

    if (tab != 'All') {
      final status = statusMap[tab] ?? '';
      result = result.where((c) => c.savedStatus == status).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.organizer.toLowerCase().contains(q) ||
                c.field.toLowerCase().contains(q) ||
                c.skillTags.any((s) => s.toLowerCase().contains(q)),
          )
          .toList();
    }

    return result;
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final theme = Theme.of(ctx);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _selectedField = 'All';
                          _selectedLocation = 'All';
                          _selectedLevel = 'All';
                        });
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SheetSection(
                  title: 'Field',
                  options: _fields,
                  selected: _selectedField,
                  onChanged: (v) => setSheetState(() => _selectedField = v),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _SheetSection(
                  title: 'Location',
                  options: _locations,
                  selected: _selectedLocation,
                  onChanged: (v) => setSheetState(() => _selectedLocation = v),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                _SheetSection(
                  title: 'Level',
                  options: _levels,
                  selected: _selectedLevel,
                  onChanged: (v) => setSheetState(() => _selectedLevel = v),
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _load();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasActiveFilters =
        _selectedField != 'All' ||
        _selectedLocation != 'All' ||
        _selectedLevel != 'All';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── SEARCH BAR ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search_rounded,
                            color: theme.hintColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: theme.textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText:
                                    'Search competition, hackathon, course...',
                                hintStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: theme.hintColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: hasActiveFilters
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasActiveFilters
                              ? AppColors.gold
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08)),
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: hasActiveFilters
                            ? AppColors.gold
                            : theme.hintColor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── FILTER CHIP ──────────────────────────────────────
            if (hasActiveFilters)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.filter_list_rounded,
                              size: 16,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Filters (active)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── STATUS TABS ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.07),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.black,
                unselectedLabelColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),

            // ── LIST ─────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  : _errorMessage.isNotEmpty
                  ? _EmptyState(message: _errorMessage, onRetry: _load)
                  : _filteredCompetitions.isEmpty
                  ? _EmptyState(
                      message: _tabController.index == 0
                          ? 'No competitions found.\nTry adjusting your filters.'
                          : 'No competitions here yet.',
                      onRetry: _load,
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppColors.gold,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _filteredCompetitions.length,
                        itemBuilder: (context, index) {
                          final comp = _filteredCompetitions[index];
                          return _CompetitionCard(
                            competition: comp,
                            onStatusChanged: (status) =>
                                _updateStatus(comp, status),
                            isDark: isDark,
                            isAiLoading: _isAiLoading,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER SHEET SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _SheetSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isActive = opt == selected;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.gold
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? AppColors.gold
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1)),
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? Colors.black
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPETITION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CompetitionCard extends StatelessWidget {
  final Competition competition;
  final ValueChanged<String> onStatusChanged;
  final bool isDark;
  final bool isAiLoading;

  const _CompetitionCard({
    required this.competition,
    required this.onStatusChanged,
    required this.isDark,
    this.isAiLoading = false,
  });

  Color _difficultyColor() {
    switch (competition.difficultyLevel.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Color _statusColor() {
    switch (competition.savedStatus) {
      case 'saved':
        return AppColors.primary;
      case 'interested':
        return AppColors.warning;
      case 'applied':
        return Colors.blue;
      case 'completed':
        return AppColors.success;
      case 'rejected':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  IconData _statusIcon() {
    switch (competition.savedStatus) {
      case 'saved':
        return Icons.bookmark_rounded;
      case 'interested':
        return Icons.star_rounded;
      case 'applied':
        return Icons.send_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.close_rounded;
      default:
        return Icons.bookmark_border_rounded;
    }
  }

  int get _fitPercent => (competition.fitScore * 100).clamp(0, 100).toInt();

  Color _fitColor() {
    if (_fitPercent >= 80) return AppColors.success;
    if (_fitPercent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = competition;
    final hasAI = c.fitReason.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.savedStatus != 'none'
              ? _statusColor().withValues(alpha: 0.35)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.07)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP: left info + right AI panel ──────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── LEFT ─────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.gold,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      _InlineTag(c.field),
                                      _InlineTag(c.locationType),
                                      if (c.teamAllowed) _InlineTag('Team'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showStatusPicker(context),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  _statusIcon(),
                                  color: c.savedStatus != 'none'
                                      ? _statusColor()
                                      : theme.hintColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          c.organizer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            _MetaItem(
                              icon: Icons.calendar_today_outlined,
                              label: 'Deadline',
                              value: c.deadline,
                            ),
                            const SizedBox(width: 12),
                            _MetaItem(
                              icon: Icons.bar_chart_rounded,
                              label: 'Level',
                              value: c.difficultyLevel,
                              valueColor: _difficultyColor(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            _MetaItem(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: c.country,
                            ),
                            if (hasAI) ...[
                              const SizedBox(width: 12),
                              _MetaItem(
                                icon: Icons.trending_up_rounded,
                                label: 'Match',
                                value: '$_fitPercent%',
                                valueColor: _fitColor(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── DIVIDER ───────────────────────────────────────
                VerticalDivider(
                  width: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.black.withValues(alpha: 0.07),
                ),

                // ── RIGHT: AI panel ───────────────────────────────
                if (hasAI)
                  SizedBox(
                    width: 148,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Match score
                          Row(
                            children: [
                              Icon(
                                Icons.gps_fixed_rounded,
                                size: 14,
                                color: _fitColor(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_fitPercent%',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _fitColor(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Why you fit here (from Gemini fitReason)
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Why you fit here',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.fitReason,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.hintColor,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Skills to gain (from Gemini missingSkills)
                          if (c.missingSkills.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 12,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Skills to gain',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: c.missingSkills
                                  .take(4)
                                  .map(
                                    (s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.warning.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        s,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],

                          // Preparation tip (from Gemini recommendedPreparation)
                          if (c.recommendedPreparation.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 12,
                                  color: theme.hintColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    c.recommendedPreparation,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: theme.hintColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Required skills (skillTags)
                          if (c.skillTags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.settings_outlined,
                                  size: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Skills Needed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: c.skillTags
                                  .take(4)
                                  .map(
                                    (s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.gold.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: 120,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: isAiLoading
                            ? [
                                const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.gold,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Analyzing\nyour fit...',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.gold,
                                    fontSize: 11,
                                  ),
                                ),
                              ]
                            : [
                                Icon(
                                  Icons.auto_awesome_outlined,
                                  color: theme.hintColor,
                                  size: 20,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'AI analysis\nnot available',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.hintColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── DIVIDER ───────────────────────────────────────────
          _FitMatchSection(
            percent: _fitPercent,
            color: _fitColor(),
            reason: c.fitReason,
            isAiLoading: isAiLoading,
            isDark: isDark,
          ),

          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.07),
          ),

          // ── APPLY BUTTON ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                // Save/status button
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    onPressed: () => _showStatusPicker(context),
                    icon: Icon(_statusIcon(), size: 15),
                    label: Text(
                      c.savedStatus == 'none' ? 'Save' : c.savedStatus,
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.savedStatus != 'none'
                          ? _statusColor()
                          : AppColors.gold,
                      side: BorderSide(
                        color: c.savedStatus != 'none'
                            ? _statusColor()
                            : AppColors.gold,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Apply button
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.tryParse(c.url);
                      if (uri != null && await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Apply Now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    final statuses = [
      ('saved', Icons.bookmark_rounded, 'Save for later'),
      ('interested', Icons.star_rounded, 'Interested'),
      ('applied', Icons.send_rounded, 'Applied'),
      ('completed', Icons.check_circle_rounded, 'Completed / Participated'),
      ('rejected', Icons.close_rounded, 'Not relevant'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...statuses.map(
                (s) => ListTile(
                  leading: Icon(
                    s.$2,
                    color: competition.savedStatus == s.$1
                        ? AppColors.gold
                        : theme.hintColor,
                  ),
                  title: Text(s.$3),
                  trailing: competition.savedStatus == s.$1
                      ? const Icon(Icons.check_rounded, color: AppColors.gold)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onStatusChanged(s.$1);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _FitMatchSection extends StatelessWidget {
  final int percent;
  final Color color;
  final String reason;
  final bool isAiLoading;
  final bool isDark;

  const _FitMatchSection({
    required this.percent,
    required this.color,
    required this.reason,
    required this.isAiLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayReason = reason.trim().isEmpty
        ? 'AI is checking your Masar profile, selected path, and skills against this competition.'
        : reason.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.tertiary.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your fit for this competition',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              if (isAiLoading) ...[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (percent / 100).clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AppColors.border,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            displayReason,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineTag extends StatelessWidget {
  final String label;
  const _InlineTag(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(
        color: AppColors.gold,
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.hintColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: theme.hintColor)),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EmptyState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
