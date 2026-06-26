import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../comp_finder_seeder.dart';
import '../models/competition_model.dart';

class CompFinderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  static const String _localStatusPrefix = 'comp_finder_status_';

  Future<List<Competition>> getRecommendedCompetitions({
    String fieldFilter = 'All',
    String locationFilter = 'All',
    String levelFilter = 'All',
  }) async {
    try {
      Query query = _db.collection('competitions');

      if (fieldFilter != 'All') {
        query = query.where('field', isEqualTo: fieldFilter);
      }
      if (locationFilter != 'All') {
        query = query.where('location_type', isEqualTo: locationFilter);
      }
      if (levelFilter != 'All') {
        query = query.where('difficulty_level', isEqualTo: levelFilter);
      }

      final snapshot = await query.get().timeout(const Duration(seconds: 5));
      if (snapshot.docs.isEmpty) {
        return _localCompetitions(
          fieldFilter: fieldFilter,
          locationFilter: locationFilter,
          levelFilter: levelFilter,
        );
      }

      final statusMap = await _loadStatusMap();

      return snapshot.docs.map((doc) {
        final comp = Competition.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        final status = statusMap[doc.id] ?? 'none';
        return comp.copyWith(savedStatus: status);
      }).toList();
    } catch (_) {
      return _localCompetitions(
        fieldFilter: fieldFilter,
        locationFilter: locationFilter,
        levelFilter: levelFilter,
      );
    }
  }

  Future<Map<String, String>> _loadStatusMap() async {
    final statusMap = <String, String>{};
    final prefs = await SharedPreferences.getInstance();

    for (final key in prefs.getKeys().where(
      (key) => key.startsWith(_localStatusPrefix),
    )) {
      final compId = key.substring(_localStatusPrefix.length);
      statusMap[compId] = prefs.getString(key) ?? 'none';
    }

    final uid = _uid;
    if (uid == null) return statusMap;

    try {
      final statusSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('competition_statuses')
          .get()
          .timeout(const Duration(seconds: 4));
      for (final doc in statusSnap.docs) {
        statusMap[doc.id] = doc.data()['status'] as String? ?? 'none';
      }
    } catch (_) {
      // Local status is enough for offline/demo use.
    }

    return statusMap;
  }

  Future<List<Competition>> _localCompetitions({
    required String fieldFilter,
    required String locationFilter,
    required String levelFilter,
  }) async {
    final statusMap = await _loadStatusMap();
    final all = CompetitionSeeder.competitions
        .asMap()
        .entries
        .map((entry) {
          final id = 'local_comp_${entry.key}_${_slug(entry.value['title'])}';
          return Competition.fromFirestore(
            entry.value,
            id,
          ).copyWith(savedStatus: statusMap[id] ?? 'none');
        })
        .where((competition) {
          final fieldMatch =
              fieldFilter == 'All' || competition.field == fieldFilter;
          final locationMatch =
              locationFilter == 'All' ||
              competition.locationType == locationFilter;
          final levelMatch =
              levelFilter == 'All' ||
              competition.difficultyLevel == levelFilter;
          return fieldMatch && locationMatch && levelMatch;
        })
        .toList();

    return all;
  }

  Future<void> updateCompetitionStatus(String compId, String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_localStatusPrefix$compId', status);

    final uid = _uid;
    if (uid == null) return;

    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('competition_statuses')
          .doc(compId)
          .set({'status': status})
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Status has already been saved locally.
    }
  }

  String _slug(Object? value) {
    return value
        .toString()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
