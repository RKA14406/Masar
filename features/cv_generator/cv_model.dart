class CvLink {
  final String label;
  final String url;

  const CvLink({required this.label, required this.url});

  factory CvLink.fromJson(Map<String, dynamic> json) {
    return CvLink(
      label: (json['label'] ?? '').toString().trim(),
      url: (json['url'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'url': url};
}

class CvProject {
  final String title;
  final String description;
  final List<String> descriptionBullets;
  final List<String> technologies;
  final String link;

  const CvProject({
    required this.title,
    this.description = '',
    this.descriptionBullets = const [],
    this.technologies = const [],
    this.link = '',
  });

  factory CvProject.fromJson(Map<String, dynamic> json) {
    return CvProject(
      title: (json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      descriptionBullets: _stringList(json['descriptionBullets']),
      technologies: _stringList(json['technologies']),
      link: (json['link'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'descriptionBullets': descriptionBullets,
      'technologies': technologies,
      'link': link,
    };
  }
}

class CvExperience {
  final String title;
  final String organization;
  final String date;
  final List<String> bullets;

  const CvExperience({
    this.title = '',
    this.organization = '',
    this.date = '',
    this.bullets = const [],
  });

  factory CvExperience.fromJson(Map<String, dynamic> json) {
    return CvExperience(
      title: (json['title'] ?? '').toString().trim(),
      organization: (json['organization'] ?? '').toString().trim(),
      date: (json['date'] ?? '').toString().trim(),
      bullets: _stringList(json['bullets']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'organization': organization,
      'date': date,
      'bullets': bullets,
    };
  }
}

class CvEducation {
  final String institution;
  final String degree;
  final String major;
  final String specialization;
  final String graduationYear;
  final String gpa;
  final List<String> details;

  const CvEducation({
    this.institution = '',
    this.degree = '',
    this.major = '',
    this.specialization = '',
    this.graduationYear = '',
    this.gpa = '',
    this.details = const [],
  });

  factory CvEducation.fromJson(Map<String, dynamic> json) {
    return CvEducation(
      institution: (json['institution'] ?? '').toString().trim(),
      degree: (json['degree'] ?? '').toString().trim(),
      major: (json['major'] ?? '').toString().trim(),
      specialization: (json['specialization'] ?? '').toString().trim(),
      graduationYear: (json['graduationYear'] ?? '').toString().trim(),
      gpa: (json['gpa'] ?? '').toString().trim(),
      details: _stringList(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'major': major,
      'specialization': specialization,
      'graduationYear': graduationYear,
      'gpa': gpa,
      'details': details,
    };
  }
}

class CvInput {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final List<CvLink> links;
  final CvEducation education;
  final String targetRole;
  final List<String> technicalSkills;
  final List<String> softSkills;
  final List<String> tools;
  final List<CvProject> projects;
  final List<String> completedSubjects;
  final List<String> achievements;
  final List<String> competitions;
  final List<CvExperience> experience;
  final List<String> languages;

  const CvInput({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.links = const [],
    this.education = const CvEducation(),
    this.targetRole = '',
    this.technicalSkills = const [],
    this.softSkills = const [],
    this.tools = const [],
    this.projects = const [],
    this.completedSubjects = const [],
    this.achievements = const [],
    this.competitions = const [],
    this.experience = const [],
    this.languages = const [],
  });

  factory CvInput.fromJson(Map<String, dynamic> json) {
    return CvInput(
      fullName: (json['fullName'] ?? '').toString().trim(),
      email: (json['email'] ?? '').toString().trim(),
      phone: (json['phone'] ?? '').toString().trim(),
      location: (json['location'] ?? '').toString().trim(),
      links: _mapList(json['links']).map(CvLink.fromJson).toList(),
      education: CvEducation.fromJson(
        Map<String, dynamic>.from(json['education'] as Map? ?? const {}),
      ),
      targetRole: (json['targetRole'] ?? '').toString().trim(),
      technicalSkills: _stringList(json['technicalSkills']),
      softSkills: _stringList(json['softSkills']),
      tools: _stringList(json['tools']),
      projects: _mapList(json['projects']).map(CvProject.fromJson).toList(),
      completedSubjects: _stringList(json['completedSubjects']),
      achievements: _stringList(json['achievements']),
      competitions: _stringList(json['competitions']),
      experience: _mapList(
        json['experience'],
      ).map(CvExperience.fromJson).toList(),
      languages: _stringList(json['languages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'links': links.map((item) => item.toJson()).toList(),
      'education': education.toJson(),
      'targetRole': targetRole,
      'technicalSkills': technicalSkills,
      'softSkills': softSkills,
      'tools': tools,
      'projects': projects.map((item) => item.toJson()).toList(),
      'completedSubjects': completedSubjects,
      'achievements': achievements,
      'competitions': competitions,
      'experience': experience.map((item) => item.toJson()).toList(),
      'languages': languages,
    };
  }

  int get totalSkills =>
      {...technicalSkills, ...softSkills, ...tools}.where(_notBlank).length;
}

class GeneratedCv {
  final CvInput input;
  final String summary;
  final List<CvEducation> education;
  final List<String> technicalSkills;
  final List<String> softSkills;
  final List<String> tools;
  final List<CvProject> projects;
  final List<String> coursework;
  final List<String> achievements;
  final List<String> competitions;
  final List<CvExperience> experience;
  final List<String> languages;

  const GeneratedCv({
    required this.input,
    this.summary = '',
    this.education = const [],
    this.technicalSkills = const [],
    this.softSkills = const [],
    this.tools = const [],
    this.projects = const [],
    this.coursework = const [],
    this.achievements = const [],
    this.competitions = const [],
    this.experience = const [],
    this.languages = const [],
  });

  factory GeneratedCv.fromJson(Map<String, dynamic> json, CvInput input) {
    final skills = Map<String, dynamic>.from(
      json['skills'] as Map? ?? const {},
    );
    return GeneratedCv(
      input: input,
      summary: (json['summary'] ?? '').toString().trim(),
      education: _mapList(json['education']).map(CvEducation.fromJson).toList(),
      technicalSkills: _stringList(skills['technical']),
      softSkills: _stringList(skills['soft']),
      tools: _stringList(skills['tools']),
      projects: _mapList(json['projects']).map(CvProject.fromJson).toList(),
      coursework: _stringList(json['coursework']),
      achievements: _stringList(json['achievements']),
      competitions: _stringList(json['competitions']),
      experience: _mapList(
        json['experience'],
      ).map(CvExperience.fromJson).toList(),
      languages: _stringList(json['languages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'summary': summary,
      'education': education.map((item) => item.toJson()).toList(),
      'skills': {
        'technical': technicalSkills,
        'tools': tools,
        'soft': softSkills,
      },
      'projects': projects.map((item) => item.toJson()).toList(),
      'coursework': coursework,
      'achievements': achievements,
      'competitions': competitions,
      'experience': experience.map((item) => item.toJson()).toList(),
      'languages': languages,
    };
  }
}

class SavedCv {
  final CvInput input;
  final GeneratedCv cv;
  final int atsScore;
  final List<String> improvementTips;
  final DateTime lastUpdated;

  const SavedCv({
    required this.input,
    required this.cv,
    required this.atsScore,
    required this.improvementTips,
    required this.lastUpdated,
  });

  factory SavedCv.fromJson(Map<String, dynamic> json) {
    final input = CvInput.fromJson(
      Map<String, dynamic>.from(json['input'] as Map? ?? const {}),
    );
    return SavedCv(
      input: input,
      cv: GeneratedCv.fromJson(
        Map<String, dynamic>.from(json['cv'] as Map? ?? const {}),
        input,
      ),
      atsScore: (json['atsScore'] as num?)?.toInt() ?? 0,
      improvementTips: _stringList(json['improvementTips']),
      lastUpdated:
          DateTime.tryParse((json['lastUpdated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'cv': cv.toJson(),
      'atsScore': atsScore,
      'improvementTips': improvementTips,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

List<String> _stringList(dynamic value) {
  return (value as List<dynamic>? ?? const [])
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList(growable: false);
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List<dynamic>? ?? const [])
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

bool _notBlank(String value) => value.trim().isNotEmpty;
