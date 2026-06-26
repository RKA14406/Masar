import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../data/datasources/subject_local_datasource.dart';
import '../../data/repositories/subject_repository.dart';
import '../../core/widgets/app_drawer.dart';
import '../specialization_selection/specialization_selection_screen.dart';

class CollegeSelectionScreen extends StatefulWidget {
  const CollegeSelectionScreen({super.key});

  @override
  State<CollegeSelectionScreen> createState() =>
      _CollegeSelectionScreenState();
}

class _CollegeSelectionScreenState extends State<CollegeSelectionScreen> {
  late final SubjectRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  List<String> _colleges = const [];

  @override
  void initState() {
    super.initState();
    _repository =
        SubjectRepository(localDataSource: SubjectLocalDataSource());
    _loadColleges();
  }

  Future<void> _loadColleges() async {
    try {
      final colleges = await _repository.getAvailableColleges();
      setState(() {
        _colleges = colleges;
        _isLoading = false;
      });
    } catch (error) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.college_load_error;
        _isLoading = false;
      });
      debugPrint('CollegeSelectionScreen error: $error');
    }
  }

  IconData _iconForCollege(String college) {
    switch (college.toLowerCase()) {
      case 'it':
      case 'information technology':
        return Icons.computer;
      case 'engineering':
        return Icons.engineering;
      case 'finance':
      case 'business':
        return Icons.business_center;
      case 'science':
        return Icons.science;
      default:
        return Icons.school;
    }
  }

  String _localizedCollegeName(String college, AppLocalizations l10n) {
    switch (college.toLowerCase()) {
      case 'it':
      case 'information technology':
        return l10n.college_it;
      case 'engineering':
        return l10n.college_engineering;
      case 'finance':
      case 'business':
        return l10n.college_business;
      case 'science':
        return l10n.college_science;
      default:
        return college;
    }
  }

  String _subtitleForCollege(String college, AppLocalizations l10n) {
    switch (college.toLowerCase()) {
      case 'it':
      case 'information technology':
        return l10n.college_it_subtitle;
      case 'engineering':
        return l10n.college_engineering_subtitle;
      case 'finance':
      case 'business':
        return l10n.college_business_subtitle;
      case 'science':
        return l10n.college_science_subtitle;
      default:
        return l10n.college_default_subtitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.college_title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
          child: Text(
            _errorMessage!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.college_select_title,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.college_select_subtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: _colleges.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final college = _colleges[index];

                  return _CollegeCard(
                    title: _localizedCollegeName(college, l10n),
                    subtitle:
                    _subtitleForCollege(college, l10n),
                    icon: _iconForCollege(college),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SpecializationSelectionScreen(
                                initialCollege: college,
                              ),
                        ),
                      );
                    },
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

class _CollegeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CollegeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}