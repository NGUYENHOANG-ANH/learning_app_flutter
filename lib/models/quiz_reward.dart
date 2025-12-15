class QuizReward {
  final int baseStars;
  final int perfectBonus;

  QuizReward({
    required this.baseStars,
    required this.perfectBonus,
  });

  factory QuizReward.fromJson(Map<String, dynamic> json) {
    return QuizReward(
      baseStars: json['baseStars'] ?? 1,
      perfectBonus: json['perfectBonus'] ?? 0,
    );
  }
}
