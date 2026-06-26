import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VALUE OBJECT — identifies a track
// ─────────────────────────────────────────────────────────────────────────────
class TrackIdentifier {
  final String college;
  final String specialization;

  const TrackIdentifier({
    required this.college,
    required this.specialization,
  });

  factory TrackIdentifier.fromJson(Map<String, dynamic> json) =>
      TrackIdentifier(
        college: (json['college'] as String? ?? '').trim(),
        specialization: (json['specialization'] as String? ?? '').trim(),
      );

  Map<String, dynamic> toJson() => {
    'college': college,
    'specialization': specialization,
  };

  @override
  bool operator ==(Object other) =>
      other is TrackIdentifier &&
          other.college.toLowerCase() == college.toLowerCase() &&
          other.specialization.toLowerCase() ==
              specialization.toLowerCase();

  @override
  int get hashCode =>
      Object.hash(college.toLowerCase(), specialization.toLowerCase());
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS SERVICE (CLEAN VERSION)
// ─────────────────────────────────────────────────────────────────────────────
class ProgressService {
  // ── keys ──────────────────────────────────────────────────────────
  static const String _selectedTrackKey = 'progress_selected_track';
  static const String _visitedTracksKey = 'progress_visited_tracks';

  static String _completedKey(String specialization) =>
      'completed_subjects_${specialization.trim().replaceAll(' ', '_')}';

  static String _lastSubjectKey(String specialization) =>
      'last_subject_${specialization.trim().replaceAll(' ', '_')}';

  // ──────────────────────────────────────────────────────────────────
  // TRACK
  // ──────────────────────────────────────────────────────────────────

  Future<void> selectTrack(String college, String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    final track =
    TrackIdentifier(college: college, specialization: specialization);

    await prefs.setString(_selectedTrackKey, jsonEncode(track.toJson()));

    final visited = await _loadVisitedFrom(prefs);
    if (!visited.contains(track)) {
      visited.add(track);
      await prefs.setString(
        _visitedTracksKey,
        jsonEncode(visited.map((t) => t.toJson()).toList()),
      );
    }
  }

  Future<TrackIdentifier?> getSelectedTrack() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedTrackKey);

    if (raw == null || raw.isEmpty) return null;

    try {
      return TrackIdentifier.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<TrackIdentifier>> getVisitedTracks() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadVisitedFrom(prefs);
  }

  // ──────────────────────────────────────────────────────────────────
  // SUBJECT PROGRESS
  // ──────────────────────────────────────────────────────────────────

  Future<Set<String>> getCompletedSubjects(String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedKey(specialization)) ?? [])
        .toSet();
  }

  Future<void> markCompleted(
      String specialization, String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCompletedSubjects(specialization);

    current.add(subjectCode);

    await prefs.setStringList(
        _completedKey(specialization), current.toList());
  }

  Future<void> markUncompleted(
      String specialization, String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCompletedSubjects(specialization);

    current.remove(subjectCode);

    await prefs.setStringList(
        _completedKey(specialization), current.toList());
  }

  Future<bool> isCompleted(
      String specialization, String subjectCode) async {
    return (await getCompletedSubjects(specialization))
        .contains(subjectCode);
  }

  Future<void> clearProgress(String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey(specialization));
  }

  // ──────────────────────────────────────────────────────────────────
  // 🔥 LAST OPENED SUBJECT (CRITICAL FOR RESUME)
  // ──────────────────────────────────────────────────────────────────

  Future<void> setLastOpenedSubject(
      String specialization,
      String subjectCode,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSubjectKey(specialization), subjectCode);
  }

  Future<String?> getLastOpenedSubject(String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSubjectKey(specialization));
  }

  // ──────────────────────────────────────────────────────────────────
  // INTERNAL
  // ──────────────────────────────────────────────────────────────────

  List<TrackIdentifier> _loadVisitedFrom(SharedPreferences prefs) {
    final raw = prefs.getString(_visitedTracksKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(TrackIdentifier.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }
}