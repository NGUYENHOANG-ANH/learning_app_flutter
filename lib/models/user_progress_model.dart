class UserProgress {
  final String userId;
  final Map<String, TopicProgress> topicProgress;
  final int totalStars;
  final DateTime lastAccessedTime;
  final List<String> unlockedAchievements;

  UserProgress({
    required this.userId,
    required this.topicProgress,
    required this.totalStars,
    required this.lastAccessedTime,
    required this.unlockedAchievements,
  });

  UserProgress copyWith({
    String? userId,
    Map<String, TopicProgress>? topicProgress,
    int? totalStars,
    DateTime? lastAccessedTime,
    List<String>? unlockedAchievements,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      topicProgress: topicProgress ?? this.topicProgress,
      totalStars: totalStars ?? this.totalStars,
      lastAccessedTime: lastAccessedTime ?? this.lastAccessedTime,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  /// Convert UserProgress to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'topicProgress': topicProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'totalStars': totalStars,
      'lastAccessedTime': lastAccessedTime.toIso8601String(),
      'unlockedAchievements': unlockedAchievements,
    };
  }

  /// Create UserProgress from JSON
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'] as String,
      topicProgress: (json['topicProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key,
              TopicProgress.fromJson(value as Map<String, dynamic>),
            ),
          ) ??
          {},
      totalStars: json['totalStars'] as int? ?? 0,
      lastAccessedTime: json['lastAccessedTime'] != null
          ? DateTime.parse(json['lastAccessedTime'] as String)
          : DateTime.now(),
      unlockedAchievements:
          List<String>.from(json['unlockedAchievements'] as List? ?? []),
    );
  }
}

class TopicProgress {
  final String topicId;
  final int starsEarned;
  final Map<String, int> levelProgress; // level -> score
  final int flashcardsReviewed;
  final DateTime lastCompletedTime;

  TopicProgress({
    required this.topicId,
    required this.starsEarned,
    required this.levelProgress,
    required this.flashcardsReviewed,
    required this.lastCompletedTime,
  });

  TopicProgress copyWith({
    String? topicId,
    int? starsEarned,
    Map<String, int>? levelProgress,
    int? flashcardsReviewed,
    DateTime? lastCompletedTime,
  }) {
    return TopicProgress(
      topicId: topicId ?? this.topicId,
      starsEarned: starsEarned ?? this.starsEarned,
      levelProgress: levelProgress ?? this.levelProgress,
      flashcardsReviewed: flashcardsReviewed ?? this.flashcardsReviewed,
      lastCompletedTime: lastCompletedTime ?? this.lastCompletedTime,
    );
  }

  /// Convert TopicProgress to JSON
  Map<String, dynamic> toJson() {
    return {
      'topicId': topicId,
      'starsEarned': starsEarned,
      'levelProgress': levelProgress,
      'flashcardsReviewed': flashcardsReviewed,
      'lastCompletedTime': lastCompletedTime.toIso8601String(),
    };
  }

  /// Create TopicProgress from JSON
  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      topicId: json['topicId'] as String,
      starsEarned: json['starsEarned'] as int? ?? 0,
      levelProgress: Map<String, int>.from(
        (json['levelProgress'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, value as int),
            ) ??
            {},
      ),
      flashcardsReviewed: json['flashcardsReviewed'] as int? ?? 0,
      lastCompletedTime: json['lastCompletedTime'] != null
          ? DateTime.parse(json['lastCompletedTime'] as String)
          : DateTime.now(),
    );
  }
}
