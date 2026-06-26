import '../../data/models/subject_model.dart';

class PathGenerator {
  static List<Subject> generateOrderedPath(List<Subject> subjects) {
    final Map<String, Subject> subjectMap = {
      for (final subject in subjects) subject.code: subject,
    };

    final List<Subject> ordered = [];
    final Set<String> visited = {};
    final Set<String> visiting = {};

    void dfs(String code) {
      if (visited.contains(code)) return;

      if (visiting.contains(code)) {
        throw Exception('Cycle detected in prerequisites at subject: $code');
      }

      final subject = subjectMap[code];
      if (subject == null) return;

      visiting.add(code);

      for (final prerequisiteCode in subject.prerequisites) {
        if (subjectMap.containsKey(prerequisiteCode)) {
          dfs(prerequisiteCode);
        }
      }

      visiting.remove(code);
      visited.add(code);
      ordered.add(subject);
    }

    for (final subject in subjects) {
      dfs(subject.code);
    }

    return ordered;
  }
}