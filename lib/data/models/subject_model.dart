class Subject {
  final String college;
  final String specialization;
  final int phase;
  final String code;
  final String name;
  final int credits;
  final List<String> prerequisites;
  final String description;
  final List<String> resources;
  final List<String> skills;

  // Added localization fields
  final String? collegeAr;
  final String? specializationAr;
  final String? nameAr;
  final String? descriptionAr;

  Subject({
    this.college = '',
    required this.specialization,
    required this.phase,
    required this.code,
    required this.name,
    required this.credits,
    required this.prerequisites,
    this.description = '',
    this.resources = const [],
    this.skills = const [],
    this.collegeAr,
    this.specializationAr,
    this.nameAr,
    this.descriptionAr,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      college: (json['college'] ?? '').toString().trim(),
      specialization: (json['specialization'] ?? '').toString().trim(),
      phase: (json['phase'] as num).toInt(),
      code: (json['code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      prerequisites: (json['prerequisites'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      description: (json['description'] ?? '').toString(),
      resources: (json['resources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false),
      collegeAr: json['college_ar']?.toString(),
      specializationAr: json['specialization_ar']?.toString(),
      nameAr: json['name_ar']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'college': college,
      'specialization': specialization,
      'phase': phase,
      'code': code,
      'name': name,
      'credits': credits,
      'prerequisites': prerequisites,
      'description': description,
      'resources': resources,
      'skills': skills,
      'college_ar': collegeAr,
      'specialization_ar': specializationAr,
      'name_ar': nameAr,
      'description_ar': descriptionAr,
    };
  }

  Subject copyWith({
    String? college,
    String? specialization,
    int? phase,
    String? code,
    String? name,
    int? credits,
    List<String>? prerequisites,
    String? description,
    List<String>? resources,
    List<String>? skills,
    String? collegeAr,
    String? specializationAr,
    String? nameAr,
    String? descriptionAr,
  }) {
    return Subject(
      college: college ?? this.college,
      specialization: specialization ?? this.specialization,
      phase: phase ?? this.phase,
      code: code ?? this.code,
      name: name ?? this.name,
      credits: credits ?? this.credits,
      prerequisites: prerequisites ?? this.prerequisites,
      description: description ?? this.description,
      resources: resources ?? this.resources,
      skills: skills ?? this.skills,
      collegeAr: collegeAr ?? this.collegeAr,
      specializationAr: specializationAr ?? this.specializationAr,
      nameAr: nameAr ?? this.nameAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
    );
  }
}
