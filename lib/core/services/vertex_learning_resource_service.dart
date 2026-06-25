import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/models/learning_resource_model.dart';
import '../../data/models/subject_model.dart';
import '../constants/vertex_search_config.dart';
import 'learning_resource_cache_service.dart';

class VertexLearningResourceService {
  final LearningResourceCacheService _cacheService =
      LearningResourceCacheService();

  String get _url =>
      'https://discoveryengine.googleapis.com/v1beta/'
      'projects/${VertexSearchConfig.projectId}/locations/global/'
      'collections/default_collection/dataStores/${VertexSearchConfig.dataStoreId}/'
      'servingConfigs/default_search:searchLite?key=${VertexSearchConfig.apiKey}';

  Future<List<LearningResource>?> getCachedResourcesForSubject(
    Subject subject,
  ) {
    return _cacheService.getCachedResources(subject.code);
  }

  Future<List<LearningResource>> searchResourcesForSubject(
    Subject subject, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await getCachedResourcesForSubject(subject);
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }
    }

    final fresh = await fetchFreshResourcesForSubject(subject);

    if (fresh.isNotEmpty) {
      await _cacheService.saveCachedResources(subject.code, fresh);
    }

    return fresh;
  }

  Future<List<LearningResource>> fetchFreshResourcesForSubject(
    Subject subject,
  ) async {
    final queries = [
      _queryPrimary(subject),
      _querySecondary(subject),
      _queryFallback(subject),
    ];

    List<LearningResource> allResults = [];

    for (final query in queries) {
      final results = await _runSearch(query);
      allResults.addAll(results);

      final selected = _selectPriorityResults(_deduplicate(allResults));
      if (selected.isNotEmpty) {
        await _cacheService.saveCachedResources(subject.code, selected);
        return selected;
      }
    }

    return _fallbackResources(subject);
  }

  Future<void> clearCacheForSubject(Subject subject) {
    return _cacheService.clearCachedResources(subject.code);
  }

  Future<List<LearningResource>> _runSearch(String query) async {
    try {
      final payload = {
        'query': query,
        'pageSize': 10,
        'boostSpec': {
          'conditionBoostSpecs': [
            {
              'condition': 'uri: ANY("coursera.org")',
              'boost': 1.0,
            },
            {
              'condition': 'uri: ANY("udemy.com")',
              'boost': 0.6,
            },
            {
              'condition': 'uri: ANY("youtube.com")',
              'boost': 0.2,
            },
            {
              'condition': 'uri: ANY("youtu.be")',
              'boost': 0.2,
            },
          ],
        },
      };

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 403 ||
          response.statusCode == 429 ||
          response.statusCode == 503) {
        return [];
      }

      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (decoded['results'] as List?) ?? [];

      return results.map((item) {
        final result = item as Map<String, dynamic>;
        final document = (result['document'] as Map<String, dynamic>?) ?? {};
        final derived =
            (document['derivedStructData'] as Map<String, dynamic>?) ?? {};

        final title = _cleanTitle(
          (derived['title'] ?? 'Untitled Course').toString(),
        );

        final link = (derived['link'] ?? '').toString().trim();
        final platform = _detectPlatform(link);

        return LearningResource(
          title: title,
          url: link,
          platform: platform,
        );
      }).where((r) {
        // Drop empty URLs
        if (r.url.isEmpty) return false;
        // Drop unknown platforms
        if (r.platform == 'Other') return false;
        // YouTube: MUST be a playlist — single video links are rejected here
        if (r.platform == 'YouTube' && !_isYoutubePlaylistUrl(r.url)) {
          return false;
        }
        return true;
      }).toList();
    } catch (e, st) {
      debugPrint('[VertexSearch] _runSearch failed: $e\n$st');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Priority selection — tiered fallback
  // ---------------------------------------------------------------------------

  /// Assigns the best possible 4-slot result set using three tiers:
  ///
  ///  Tier 1 (best case)  → Coursera×2, Udemy×1,    YouTube×1
  ///  Tier 2 (mid case)   → Udemy×2,    Coursera×1,  YouTube×1
  ///  Tier 3 (worst case) → YouTube×2,  Coursera×1,  Udemy×1
  ///
  /// Returns an empty list if not even Tier 3 can be satisfied;
  /// the caller will then fall back to [_fallbackResources].
  List<LearningResource> _selectPriorityResults(List<LearningResource> input) {
    final coursera = <LearningResource>[];
    final udemy = <LearningResource>[];
    final youtube = <LearningResource>[];

    for (final r in input) {
      switch (r.platform) {
        case 'Coursera':
          coursera.add(r);
          break;
        case 'Udemy':
          udemy.add(r);
          break;
        case 'YouTube':
          // _isYoutubePlaylistUrl is already enforced in _runSearch, but
          // guard again here so this method stays self-contained.
          if (_isYoutubePlaylistUrl(r.url)) {
            youtube.add(r);
          }
          break;
      }
    }

    // --- Tier 1: Best case — Coursera×2, Udemy×1, YouTube×1 ----------------
    if (coursera.length >= 2 && udemy.isNotEmpty && youtube.isNotEmpty) {
      return [
        coursera[0],
        coursera[1],
        udemy[0],
        youtube[0],
      ];
    }

    // --- Tier 2: Mid case — Udemy×2, Coursera×1, YouTube×1 -----------------
    if (udemy.length >= 2 && coursera.isNotEmpty && youtube.isNotEmpty) {
      return [
        udemy[0],
        udemy[1],
        coursera[0],
        youtube[0],
      ];
    }

    // --- Tier 3: Worst case — YouTube×2, Coursera×1, Udemy×1 ---------------
    if (youtube.length >= 2 && coursera.isNotEmpty && udemy.isNotEmpty) {
      return [
        youtube[0],
        youtube[1],
        coursera[0],
        udemy[0],
      ];
    }

    // Not enough variety yet — signal caller to keep accumulating results
    return [];
  }

  // ---------------------------------------------------------------------------
  // Query builders
  // ---------------------------------------------------------------------------

  String _cleanName(String name) {
    return name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
  }

  String _queryPrimary(Subject subject) {
    final name = _cleanName(subject.name);
    return '$name full course playlist';
  }

  String _querySecondary(Subject subject) {
    final name = _cleanName(subject.name);
    final skills = subject.skills.take(2).join(' ').trim();

    if (skills.isEmpty) {
      return '$name tutorial playlist';
    }

    return '$name $skills tutorial playlist';
  }

  String _queryFallback(Subject subject) {
    final name = _cleanName(subject.name);
    return '$name tutorial playlist youtube';
  }

  // ---------------------------------------------------------------------------
  // Platform helpers
  // ---------------------------------------------------------------------------

  String _detectPlatform(String url) {
    final lower = url.toLowerCase();

    if (lower.contains('coursera.org')) return 'Coursera';
    if (lower.contains('udemy.com')) return 'Udemy';
    if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return 'YouTube';
    }

    return 'Other';
  }

  /// Returns true only for YouTube URLs that point to a playlist.
  ///
  /// Accepted forms:
  ///   • youtube.com/playlist?list=PLxxxx
  ///   • youtube.com/watch?v=xxxx&list=PLxxxx  (video inside a named playlist)
  ///   • youtu.be/xxxx?list=PLxxxx             (short link with playlist param)
  ///
  /// Single video links (no `list` param, no `/playlist` path) are rejected.
  bool _isYoutubePlaylistUrl(String url) {
    final lower = url.toLowerCase();

    if (!(lower.contains('youtube.com') || lower.contains('youtu.be'))) {
      return false;
    }

    // Explicit /playlist path always qualifies
    if (lower.contains('youtube.com/playlist')) return true;

    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    // Must have a non-empty `list` query parameter
    final listParam = (uri.queryParameters['list'] ?? '').trim();
    if (listParam.isEmpty) return false;

    // Accepted path patterns that can carry a playlist param
    final path = uri.path.toLowerCase();
    final isShortLink = uri.host.toLowerCase().contains('youtu.be');
    final isWatchLink = path.contains('/watch');
    final isPlaylistPath = path.contains('/playlist');

    return isShortLink || isWatchLink || isPlaylistPath;
  }

  // ---------------------------------------------------------------------------
  // Misc helpers
  // ---------------------------------------------------------------------------

  String _cleanTitle(String title) {
    return title
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<LearningResource> _deduplicate(List<LearningResource> resources) {
    final seen = <String>{};
    final output = <LearningResource>[];

    for (final resource in resources) {
      if (seen.add(resource.url)) {
        output.add(resource);
      }
    }

    return output;
  }

  /// Hard fallback when all search queries fail to produce a tiered result.
  /// Uses generic search URLs so the user always gets something actionable.
  /// Note: the YouTube URL includes `sp=EgIQAw%3D%3D` which filters
  /// YouTube search results to playlists only.
  List<LearningResource> _fallbackResources(Subject subject) {
    final name = Uri.encodeComponent(subject.name);
    return [
      LearningResource(
        title: 'Coursera: ${subject.name}',
        url: 'https://www.coursera.org/search?query=$name',
        platform: 'Coursera',
      ),
      LearningResource(
        title: 'Udemy: ${subject.name}',
        url: 'https://www.udemy.com/courses/search/?q=$name',
        platform: 'Udemy',
      ),
      LearningResource(
        title: 'YouTube Playlists: ${subject.name}',
        url:
            'https://www.youtube.com/results?search_query=$name+full+course+playlist&sp=EgIQAw%253D%253D',
        platform: 'YouTube',
      ),
    ];
  }
}
