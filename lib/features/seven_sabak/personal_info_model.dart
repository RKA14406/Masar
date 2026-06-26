class PersonalInfo {
  final String fullName;
  final String email;
  final String major;
  final List<String> skills;
  final String goals;
  final String country;
  final String enrollmentQuarter;
  final String enrollmentYear;
  final String gender;

  const PersonalInfo({
    this.fullName = '',
    this.email = '',
    this.major = '',
    this.skills = const [],
    this.goals = '',
    this.country = '',
    this.enrollmentQuarter = '',
    this.enrollmentYear = '',
    this.gender = '',
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      major: (json['major'] ?? '').toString(),
      skills: _stringList(json['skills']),
      goals: (json['goals'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      enrollmentQuarter: (json['enrollmentQuarter'] ?? '').toString(),
      enrollmentYear: (json['enrollmentYear'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'major': major,
      'skills': skills,
      'goals': goals,
      'country': country,
      'enrollmentQuarter': enrollmentQuarter,
      'enrollmentYear': enrollmentYear,
      'gender': gender,
    };
  }

  static List<String> _stringList(dynamic value) {
    return (value as List<dynamic>? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}
