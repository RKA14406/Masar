import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ada2k_service.dart';
import 'ada2k_model.dart';
import '../../core/widgets/app_drawer.dart';

class Ada2kScreen extends StatefulWidget {
  const Ada2kScreen({super.key});

  @override
  State<Ada2kScreen> createState() => _Ada2kScreenState();
}

class _Ada2kScreenState extends State<Ada2kScreen> {
  final Ada2kService _service = Ada2kService();
  Ada2kSummary? _summary;
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final summary = await _service.fetchSummary(1);
    if (!mounted) return;
    setState(() {
      _summary = summary;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _summary != null) {
        final userIndex = _summary!.leaderboard.indexWhere(
          (e) => e.name == _summary!.user.name,
        );
        if (userIndex != -1) {
          final offset = (userIndex * 60.0) - 95.0; // Center it somewhat
          _scrollController.animateTo(
            offset < 0 ? 0 : offset,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateDaysLeft(String targetDateStr) {
    try {
      final targetDate = DateTime.parse(targetDateStr);
      final now = DateTime.now();
      final difference = targetDate.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  void _showModifyGoalBottomSheet(BuildContext context) {
    int selectedPercent = _summary!.goal.targetCompletionPercent;
    DateTime selectedDate = DateTime.parse(_summary!.goal.targetDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Modify Your Goal",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Target Completion: $selectedPercent%",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    value: selectedPercent.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 90,
                    label: "$selectedPercent%",
                    onChanged: (val) {
                      setModalState(() => selectedPercent = val.toInt());
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Target Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Select New Date"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);
                      await _service.updateGoal(
                        1,
                        selectedPercent,
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      );
                      await _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text(
                      "Save New Goal",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ada2k Performance'),
        backgroundColor: theme.colorScheme.surface,
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load data.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCircularProgress(theme, _summary!),
                    const SizedBox(height: 16),
                    _buildScoreBar(theme, _summary!),
                    const SizedBox(height: 16),
                    _buildTimeLeft(theme, _summary!),
                    const SizedBox(height: 16),
                    _buildGoalCommitment(theme, _summary!),
                    const SizedBox(height: 24),
                    _buildLeaderboard(theme, _summary!),
                    const SizedBox(height: 24),
                    _buildAnalysis(theme, _summary!),
                    const SizedBox(height: 16),
                    _buildRecommendation(theme, _summary!),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCircularProgress(ThemeData theme, Ada2kSummary summary) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Overall Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: summary.progress.completionPercent / 100,
                    strokeWidth: 12,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                  Center(
                    child: Text(
                      '${summary.progress.completionPercent}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(ThemeData theme, Ada2kSummary summary) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value:
                    summary.progress.completedSubjects /
                    summary.progress.totalSubjects,
                minHeight: 12,
                color: theme.colorScheme.secondary,
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${summary.progress.completedSubjects} / ${summary.progress.totalSubjects} tasks done',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeLeft(ThemeData theme, Ada2kSummary summary) {
    final daysLeft = _calculateDaysLeft(summary.goal.targetDate);
    final targetDate = DateTime.parse(summary.goal.targetDate);
    final monthName = DateFormat('MMM').format(targetDate).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Calendar Icon Style
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    '${targetDate.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Left Until Deadline',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                '$daysLeft Days Left',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getEmojiForScore(int score) {
    if (score <= 50) return '😠';
    if (score <= 70) return '😢';
    if (score <= 89) return '😀';
    return '🤩';
  }

  Widget _buildGoalCommitment(ThemeData theme, Ada2kSummary summary) {
    final emoji = _getEmojiForScore(summary.progress.completionPercent);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Commitment',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 32)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Your Goal: ${summary.goal.targetCompletionPercent}% by ${summary.goal.targetDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              summary.status.insight,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showModifyGoalBottomSheet(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Modify Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(ThemeData theme, Ada2kSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cohort Rank Leaderboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surface,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: summary.leaderboard.length,
              itemBuilder: (context, index) {
                final entry = summary.leaderboard[index];
                final isMe = entry.name == summary.user.name;

                return Container(
                  height: 60,
                  color: isMe
                      ? theme.colorScheme.primaryContainer
                      : (index % 2 == 0 ? Colors.grey[50] : Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '#${entry.rank}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isMe
                                ? theme.colorScheme.primary
                                : Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.name + (isMe ? ' (You)' : ''),
                          style: TextStyle(
                            fontWeight: isMe
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                            color: isMe
                                ? theme.colorScheme.onPrimaryContainer
                                : Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMe ? 12 : 0,
                          vertical: isMe ? 6 : 0,
                        ),
                        decoration: isMe
                            ? BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 4,
                                  ),
                                ],
                              )
                            : null,
                        child: Text(
                          '${entry.score} pts',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? theme.colorScheme.onPrimary
                                : Colors.grey[700],
                            fontSize: isMe ? 16 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysis(ThemeData theme, Ada2kSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Detailed Analysis',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.analysis.detailedAnalysis,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                if (summary.analysis.performanceHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Performance Trend (6 Weeks)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  'W${value.toInt() + 1}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: summary.analysis.performanceHistory
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value))
                                .toList(),
                            isCurved: true,
                            color: theme.colorScheme.primary,
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation(ThemeData theme, Ada2kSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber[700]),
            const SizedBox(width: 8),
            Text(
              'Recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...summary.analysis.actionItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(color: Colors.amber[600]!, width: 6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.brown[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
