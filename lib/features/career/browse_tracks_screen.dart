import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_data_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';
import '../path_view/path_view_screen.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class _Track {
  final String college;
  final String collegeAr;
  final String specialization;
  final String specializationAr;

  const _Track({
    required this.college,
    required this.collegeAr,
    required this.specialization,
    required this.specializationAr,
  });

  @override
  bool operator ==(Object other) =>
      other is _Track &&
          other.college == college &&
          other.specialization == specialization;

  @override
  int get hashCode => Object.hash(college, specialization);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class BrowseTracksScreen extends StatefulWidget {
  const BrowseTracksScreen({super.key});

  @override
  State<BrowseTracksScreen> createState() => _BrowseTracksScreenState();
}

class _BrowseTracksScreenState extends State<BrowseTracksScreen> {
  List<_Track> _allTracks = [];
  List<_Track> _filteredTracks = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTracks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load JSON from backend (with local asset fallback) and extract unique college+specialization pairs
  Future<void> _loadTracks() async {
    try {
      List<dynamic> items;
      try {
        items = await AppDataService().fetchSubjects();
      } catch (networkError) {
        print('BrowseTracksScreen: backend failed ($networkError), trying local asset');
        final raw = await rootBundle.loadString(
          'assets/data/vision_career_phase1_phase2_master_dataset_rebuilt.json',
        );
        if (raw.isEmpty) {
          throw Exception('Local asset is empty and backend is unavailable');
        }
        try {
          items = jsonDecode(raw) as List<dynamic>;
        } catch (e) {
          throw Exception('Failed to parse local asset: $e');
        }
      }

      final seen = <_Track>{};
      final tracks = <_Track>[];

      for (final item in items) {
        final track = _Track(
          college: item['college'] as String,
          collegeAr: item['college_ar'] as String? ?? '',
          specialization: item['specialization'] as String,
          specializationAr: item['specialization_ar'] as String? ?? '',
        );
        if (seen.add(track)) {
          tracks.add(track);
        }
      }

      // Sort: college first, then specialization
      tracks.sort((a, b) {
        final c = a.college.compareTo(b.college);
        return c != 0 ? c : a.specialization.compareTo(b.specialization);
      });

      if (!mounted) return;
      setState(() {
        _allTracks = tracks;
        _filteredTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTracks(String query) {
    if (query.isEmpty) {
      setState(() => _filteredTracks = _allTracks);
      return;
    }

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final q = query.toLowerCase();

    setState(() {
      _filteredTracks = _allTracks.where((track) {
        final title = isRtl ? track.specializationAr : track.specialization;
        final college = isRtl ? track.collegeAr : track.college;
        // Also search the other language so bilingual queries work
        return title.toLowerCase().contains(q) ||
            college.toLowerCase().contains(q) ||
            track.specialization.toLowerCase().contains(q) ||
            track.specializationAr.contains(query) ||
            track.college.toLowerCase().contains(q) ||
            track.collegeAr.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.browseTracks),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterTracks,
              decoration: InputDecoration(
                hintText: l10n.searchSpecialty,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterTracks('');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ErrorView(message: _error!, onRetry: _loadTracks)
                : _filteredTracks.isEmpty
                ? Center(child: Text(l10n.searchSpecialty))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredTracks.length,
              itemBuilder: (context, index) {
                final track = _filteredTracks[index];
                final title = isRtl
                    ? track.specializationAr
                    : track.specialization;
                final college =
                isRtl ? track.collegeAr : track.college;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(college),
                        ],
                      ),
                    ),
                    trailing: Icon(
                      isRtl
                          ? Icons.arrow_back_ios_new
                          : Icons.arrow_forward_ios,
                      size: 16,
                    ),
                    onTap: () async {
                      await ProgressService().selectTrack(
                        track.college,
                        track.specialization,
                      );
                      if (!context.mounted) return;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PathViewScreen(
                            college: track.college,
                            specialization: track.specialization,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error widget ─────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
