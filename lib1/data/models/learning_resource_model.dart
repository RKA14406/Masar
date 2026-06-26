class LearningResource {
  final String title;
  final String url;
  final String platform;

  const LearningResource({
    required this.title,
    required this.url,
    required this.platform,
  });

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      title: (json['title'] ?? '') as String,
      url: (json['url'] ?? '') as String,
      platform: (json['platform'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'platform': platform,
    };
  }
}