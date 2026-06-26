import '../../data/models/subject_model.dart';
import 'career_llm_service.dart';

class CareerPhase3Builder {
  const CareerPhase3Builder();

  List<Subject> buildNodes({
    required String college,
    required String specialization,
    required List<CareerTopic> topics,
  }) {
    final normalizedTopics = topics.take(5).toList(growable: false);
    final nodes = <Subject>[];

    for (int index = 0; index < normalizedTopics.length; index++) {
      final topic = normalizedTopics[index];
      final code = _buildNodeCode(
        college: college,
        specialization: specialization,
        index: index,
      );

      nodes.add(
        Subject(
          college: college,
          specialization: specialization,
          phase: 3,
          code: code,
          name: topic.title,
          credits: 0,
          prerequisites: index == 0 ? const [] : [nodes[index - 1].code],
          description: _buildDescription(topic),
          skills: _normalizeSkills(topic.skillsGained),
          resources: const [],
        ),
      );
    }

    return nodes;
  }

  String _buildNodeCode({
    required String college,
    required String specialization,
    required int index,
  }) {
    final shortCollege = college
        .toUpperCase()
        .replaceAll('&', 'AND')
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final shortSpec = specialization
        .toUpperCase()
        .replaceAll('&', 'AND')
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return 'P3_${shortCollege}_${shortSpec}_${index + 1}';
  }

  String _buildDescription(CareerTopic topic) {
    final relatedJobs = topic.relatedJobs.isEmpty
        ? ''
        : '\n\nRelated jobs: ${topic.relatedJobs.join(', ')}';

    return '${topic.description.trim()}$relatedJobs';
  }

  List<String> _normalizeSkills(List<String> skills) {
    final seen = <String>{};
    final output = <String>[];

    for (final skill in skills) {
      final normalized = skill.trim();
      if (normalized.isEmpty) continue;
      if (seen.add(normalized.toLowerCase())) {
        output.add(normalized);
      }
    }

    return output;
  }
}
