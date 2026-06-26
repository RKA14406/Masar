class PortfolioProjectInput {
  final String title;
  final String description;
  final List<String> technologies;
  final String link;

  const PortfolioProjectInput({
    required this.title,
    required this.description,
    this.technologies = const [],
    this.link = '',
  });

  factory PortfolioProjectInput.fromJson(Map<String, dynamic> json) {
    return PortfolioProjectInput(
      title: (json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      technologies: _stringList(json['technologies']),
      link: (json['link'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'technologies': technologies,
      'link': link,
    };
  }
}

class PortfolioLink {
  final String label;
  final String url;

  const PortfolioLink({required this.label, required this.url});

  factory PortfolioLink.fromJson(Map<String, dynamic> json) {
    return PortfolioLink(
      label: (json['label'] ?? '').toString().trim(),
      url: (json['url'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'url': url};
  }
}

class PortfolioInput {
  final String fullName;
  final String major;
  final String goalTitle;
  final String manualSummary;
  final List<String> skills;
  final List<PortfolioProjectInput> projects;
  final List<String> achievements;
  final List<String> competitions;
  final List<PortfolioLink> links;
  final List<String> completedSubjects;
  final String learningProgress;
  final List<String> targetRoles;

  const PortfolioInput({
    required this.fullName,
    required this.major,
    required this.goalTitle,
    this.manualSummary = '',
    this.skills = const [],
    this.projects = const [],
    this.achievements = const [],
    this.competitions = const [],
    this.links = const [],
    this.completedSubjects = const [],
    this.learningProgress = '',
    this.targetRoles = const [],
  });

  factory PortfolioInput.fromJson(Map<String, dynamic> json) {
    return PortfolioInput(
      fullName: (json['fullName'] ?? '').toString().trim(),
      major: (json['major'] ?? '').toString().trim(),
      goalTitle: (json['goalTitle'] ?? '').toString().trim(),
      manualSummary: (json['manualSummary'] ?? '').toString().trim(),
      skills: _stringList(json['skills']),
      projects: _mapList(json['projects'])
          .map(PortfolioProjectInput.fromJson)
          .where((project) => project.title.isNotEmpty)
          .toList(growable: false),
      achievements: _stringList(json['achievements']),
      competitions: _stringList(json['competitions']),
      links: _mapList(json['links'])
          .map(PortfolioLink.fromJson)
          .where((link) => link.label.isNotEmpty && link.url.isNotEmpty)
          .toList(growable: false),
      completedSubjects: _stringList(json['completedSubjects']),
      learningProgress: (json['learningProgress'] ?? '').toString().trim(),
      targetRoles: _stringList(json['targetRoles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'major': major,
      'goalTitle': goalTitle,
      'manualSummary': manualSummary,
      'skills': skills,
      'projects': projects.map((project) => project.toJson()).toList(),
      'achievements': achievements,
      'competitions': competitions,
      'links': links.map((link) => link.toJson()).toList(),
      'completedSubjects': completedSubjects,
      'learningProgress': learningProgress,
      'targetRoles': targetRoles,
    };
  }
}

class GeneratedPortfolio {
  final String headline;
  final String summary;
  final List<String> skills;
  final List<PortfolioProjectInput> projects;
  final String academicProgress;
  final List<String> achievements;
  final List<String> competitions;
  final List<PortfolioLink> links;

  const GeneratedPortfolio({
    required this.headline,
    required this.summary,
    this.skills = const [],
    this.projects = const [],
    this.academicProgress = '',
    this.achievements = const [],
    this.competitions = const [],
    this.links = const [],
  });

  factory GeneratedPortfolio.fromJson(Map<String, dynamic> json) {
    return GeneratedPortfolio(
      headline: (json['headline'] ?? '').toString().trim(),
      summary: (json['summary'] ?? '').toString().trim(),
      skills: _stringList(json['skills']),
      projects: _mapList(json['projects'])
          .map(PortfolioProjectInput.fromJson)
          .where((project) => project.title.isNotEmpty)
          .toList(growable: false),
      academicProgress: (json['academicProgress'] ?? '').toString().trim(),
      achievements: _stringList(json['achievements']),
      competitions: _stringList(json['competitions']),
      links: _mapList(json['links'])
          .map(PortfolioLink.fromJson)
          .where((link) => link.label.isNotEmpty && link.url.isNotEmpty)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'summary': summary,
      'skills': skills,
      'projects': projects.map((project) => project.toJson()).toList(),
      'academicProgress': academicProgress,
      'achievements': achievements,
      'competitions': competitions,
      'links': links.map((link) => link.toJson()).toList(),
    };
  }
}

class SavedPortfolio {
  final PortfolioInput input;
  final GeneratedPortfolio portfolio;
  final DateTime lastUpdated;

  const SavedPortfolio({
    required this.input,
    required this.portfolio,
    required this.lastUpdated,
  });

  factory SavedPortfolio.fromJson(Map<String, dynamic> json) {
    return SavedPortfolio(
      input: PortfolioInput.fromJson(
        Map<String, dynamic>.from(json['input'] as Map? ?? const {}),
      ),
      portfolio: GeneratedPortfolio.fromJson(
        Map<String, dynamic>.from(json['portfolio'] as Map? ?? const {}),
      ),
      lastUpdated:
          DateTime.tryParse((json['lastUpdated'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': input.toJson(),
      'portfolio': portfolio.toJson(),
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
