class Topic {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String color; // Hex color
  final int totalFlashcards;
  final int totalQuizzes;
  final bool isLocked;
  final int requiredStars; // Số sao cần để mở khóa (tuỳ chọn)

  Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.color,
    required this.totalFlashcards,
    required this.totalQuizzes,
    this.isLocked = false,
    this.requiredStars = 0,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      color: json['color'] as String,
      totalFlashcards: json['totalFlashcards'] as int,
      totalQuizzes: json['totalQuizzes'] as int,
      isLocked: json['isLocked'] as bool? ?? false,
      requiredStars: json['requiredStars'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'color': color,
      'totalFlashcards': totalFlashcards,
      'totalQuizzes': totalQuizzes,
      'isLocked': isLocked,
      'requiredStars': requiredStars,
    };
  }

  // 🔹 CHỈ BỔ SUNG PHẦN NÀY
  Topic copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? color,
    int? totalFlashcards,
    int? totalQuizzes,
    bool? isLocked,
    int? requiredStars,
  }) {
    return Topic(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      totalFlashcards: totalFlashcards ?? this.totalFlashcards,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      isLocked: isLocked ?? this.isLocked,
      requiredStars: requiredStars ?? this.requiredStars,
    );
  }
}
