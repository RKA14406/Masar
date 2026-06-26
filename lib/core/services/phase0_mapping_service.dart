import '../../data/datasources/subject_local_datasource.dart';
import '../../data/models/subject_model.dart';
import '../../data/repositories/subject_repository.dart';

class Phase0SpecialtyOption {
  final String specialtyKey;
  final String title;
  final String collegeKey;
  final String collegeTitle;
  final String specializationKey;
  final String datasetSpecialization;
  final List<String> aliases;

  const Phase0SpecialtyOption({
    required this.specialtyKey,
    required this.title,
    required this.collegeKey,
    required this.collegeTitle,
    required this.specializationKey,
    required this.datasetSpecialization,
    this.aliases = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'specialty_key': specialtyKey,
      'title': title,
      'college_key': collegeKey,
      'college_title': collegeTitle,
      'specialization_key': specializationKey,
      'dataset_specialization': datasetSpecialization,
      'aliases': aliases,
    };
  }
}

class Phase0MappedSpecialty {
  final String specialtyKey;
  final String title;
  final String collegeKey;
  final String collegeTitle;
  final String? collegeTitleAr;
  final String specializationKey;
  final String datasetSpecialization;
  final String? datasetSpecializationAr;
  final List<String> aliases;

  const Phase0MappedSpecialty({
    required this.specialtyKey,
    required this.title,
    required this.collegeKey,
    required this.collegeTitle,
    this.collegeTitleAr,
    required this.specializationKey,
    required this.datasetSpecialization,
    this.datasetSpecializationAr,
    this.aliases = const [],
  });

  Phase0SpecialtyOption toAllowedOption() {
    return Phase0SpecialtyOption(
      specialtyKey: specialtyKey,
      title: title,
      collegeKey: collegeKey,
      collegeTitle: collegeTitle,
      specializationKey: specializationKey,
      datasetSpecialization: datasetSpecialization,
      aliases: aliases,
    );
  }
}

class Phase0MappingService {
  Phase0MappingService({SubjectRepository? repository})
      : _repository = repository ??
      SubjectRepository(localDataSource: SubjectLocalDataSource());

  final SubjectRepository _repository;

  Future<List<Phase0SpecialtyOption>> getAllowedSpecialties() async {
    final validMappings = await getValidRegistry();
    return validMappings.map((item) => item.toAllowedOption()).toList(growable: false);
  }

  Future<List<Phase0MappedSpecialty>> getValidRegistry() async {
    final subjects = await _repository.getAllSubjects();
    final grouped = <String, List<Subject>>{};

    for (final subject in subjects) {
      final college = subject.college.trim();
      final specialization = subject.specialization.trim();

      if (college.isEmpty || specialization.isEmpty) {
        continue;
      }

      final compoundKey = '${_normalize(college)}::${_normalize(specialization)}';
      grouped.putIfAbsent(compoundKey, () => <Subject>[]).add(subject);
    }

    final registry = grouped.entries.map((entry) {
      final first = entry.value.first;
      final collegeTitle = first.college.trim();
      final specializationTitle = first.specialization.trim();
      final collegeKey = _slugify(collegeTitle);
      final specializationKey = _slugify(specializationTitle);
      final specialtyKey = '${collegeKey}__$specializationKey';

      final collegeTitleAr = entry.value
          .map((s) => s.collegeAr?.trim())
          .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
      final specializationAr = entry.value
          .map((s) => s.specializationAr?.trim())
          .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);

      return Phase0MappedSpecialty(
        specialtyKey: specialtyKey,
        title: specializationTitle,
        collegeKey: collegeKey,
        collegeTitle: collegeTitle,
        collegeTitleAr: collegeTitleAr,
        specializationKey: specializationKey,
        datasetSpecialization: specializationTitle,
        datasetSpecializationAr: specializationAr,
        aliases: _buildAliases(
          collegeTitle: collegeTitle,
          specializationTitle: specializationTitle,
        ),
      );
    }).toList();

    registry.sort((a, b) {
      final collegeCompare =
      a.collegeTitle.toLowerCase().compareTo(b.collegeTitle.toLowerCase());
      if (collegeCompare != 0) {
        return collegeCompare;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return registry;
  }

  Future<List<String>> getAvailableCollegeTitles() async {
    final registry = await getValidRegistry();
    final colleges = registry
        .map((item) => item.collegeTitle)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return colleges;
  }

  Future<List<Phase0MappedSpecialty>> getSpecialtiesForCollege(String college) async {
    final registry = await getValidRegistry();
    final normalizedCollege = _normalize(college);

    return registry
        .where((item) => _normalize(item.collegeTitle) == normalizedCollege)
        .toList(growable: false);
  }

  Future<Phase0MappedSpecialty?> mapSpecialtyKey(String specialtyKey) async {
    final registry = await getValidRegistry();
    final normalizedKey = _normalize(specialtyKey);

    for (final item in registry) {
      if (_normalize(item.specialtyKey) == normalizedKey) {
        return item;
      }
    }

    return null;
  }

  Future<Phase0MappedSpecialty?> mapCollegeAndSpecialization({
    required String college,
    required String specialization,
  }) async {
    final registry = await getValidRegistry();
    final normalizedCollege = _normalize(college);
    final normalizedSpecialization = _normalize(specialization);

    for (final item in registry) {
      if (_normalize(item.collegeTitle) == normalizedCollege &&
          _normalize(item.datasetSpecialization) == normalizedSpecialization) {
        return item;
      }
    }

    return null;
  }

  Future<Phase0MappedSpecialty> requireMapping(String specialtyKey) async {
    final mapping = await mapSpecialtyKey(specialtyKey);
    if (mapping == null) {
      throw const FormatException(
        'The selected specialty could not be mapped to the local dataset.',
      );
    }
    return mapping;
  }

  List<String> _buildAliases({
    required String collegeTitle,
    required String specializationTitle,
  }) {
    final aliases = <String>{
      specializationTitle,
      specializationTitle.toLowerCase(),
      '$specializationTitle $collegeTitle',
      '$collegeTitle $specializationTitle',
      specializationTitle.replaceAll('&', 'and'),
      specializationTitle.replaceAll('&', 'and').toLowerCase(),
    };

    return aliases.where((item) => item.trim().isNotEmpty).toList(growable: false);
  }

  String _slugify(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    var previousWasSeparator = false;

    for (final rune in lower.runes) {
      final isLetter = rune >= 97 && rune <= 122;
      final isDigit = rune >= 48 && rune <= 57;

      if (isLetter || isDigit) {
        buffer.writeCharCode(rune);
        previousWasSeparator = false;
      } else if (!previousWasSeparator) {
        buffer.write('_');
        previousWasSeparator = true;
      }
    }

    final result = buffer.toString().replaceAll(RegExp(r'^_+|_+$'), '');
    return result.isEmpty ? 'unknown' : result;
  }

  String _normalize(String value) => value.trim().toLowerCase();
}