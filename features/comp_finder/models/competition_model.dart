class Competition {
  final String id;
  final String title;
  final String organizer;
  final String field;
  final List<String> majorTags;
  final List<String> skillTags;
  final String deadline;
  final String locationType;
  final String country;
  final String url;
  final String difficultyLevel;
  final bool teamAllowed;

  // AI-generated fields (filled after Gemini call)
  final String fitReason;
  final List<String> missingSkills;
  final String recommendedPreparation;

  // AI fit score (0.0 – 1.0, from Gemini)
  final double fitScore;

  // User state
  final String
  savedStatus; // none, saved, interested, applied, completed, rejected

  const Competition({
    required this.id,
    required this.title,
    required this.organizer,
    required this.field,
    required this.majorTags,
    required this.skillTags,
    required this.deadline,
    required this.locationType,
    required this.country,
    required this.url,
    required this.difficultyLevel,
    required this.teamAllowed,
    this.fitReason = '',
    this.missingSkills = const [],
    this.recommendedPreparation = '',
    this.fitScore = 0.0,
    this.savedStatus = 'none',
  });

  factory Competition.fromFirestore(Map<String, dynamic> data, String id) {
    return Competition(
      id: id,
      title: data['title'] ?? '',
      organizer: data['organizer'] ?? '',
      field: data['field'] ?? '',
      majorTags: List<String>.from(data['major_tags'] ?? []),
      skillTags: List<String>.from(data['skill_tags'] ?? []),
      deadline: data['deadline'] ?? '',
      locationType: data['location_type'] ?? '',
      country: data['country'] ?? '',
      url: data['url'] ?? '',
      difficultyLevel: data['difficulty_level'] ?? '',
      teamAllowed: data['team_allowed'] ?? false,
      fitReason: data['fit_reason'] ?? '',
      missingSkills: List<String>.from(data['missing_skills'] ?? []),
      recommendedPreparation: data['recommended_preparation'] ?? '',
      fitScore: (data['fit_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Competition copyWith({
    String? fitReason,
    List<String>? missingSkills,
    String? recommendedPreparation,
    double? fitScore,
    String? savedStatus,
  }) {
    return Competition(
      id: id,
      title: title,
      organizer: organizer,
      field: field,
      majorTags: majorTags,
      skillTags: skillTags,
      deadline: deadline,
      locationType: locationType,
      country: country,
      url: url,
      difficultyLevel: difficultyLevel,
      teamAllowed: teamAllowed,
      fitReason: fitReason ?? this.fitReason,
      missingSkills: missingSkills ?? this.missingSkills,
      recommendedPreparation:
          recommendedPreparation ?? this.recommendedPreparation,
      fitScore: fitScore ?? this.fitScore,
      savedStatus: savedStatus ?? this.savedStatus,
    );
  }
}
