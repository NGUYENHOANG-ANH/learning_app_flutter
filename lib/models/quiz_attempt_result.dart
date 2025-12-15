/// ✅ Quiz attempt result with time + streak
class QuizAttemptResult {
  final String quizId;
  final String topicId;
  final int total;
  final int correct;
  final bool isPerfect;
  final int starsEarned;
  final DateTime completedAt;
  final int? timeSpentSeconds;
  final int longestStreak;
  final bool timeoutOccurred;

  QuizAttemptResult({
    required this.quizId,
    required this.topicId,
    required this.total,
    required this.correct,
    required this.completedAt,
    this.timeSpentSeconds,
    this.longestStreak = 0,
    this.timeoutOccurred = false,
  })  : isPerfect = correct == total,
        starsEarned = _calculateStars(correct, total);

  static int _calculateStars(int correct, int total) {
    if (correct == total) return total;
    final percentage = (correct / total) * 100;
    if (percentage >= 80) return ((total * 0.8).ceil());
    if (percentage >= 60) return ((total * 0.67).ceil());
    return 1;
  }

  bool get hasTimeBonus => timeSpentSeconds != null && timeSpentSeconds! < 30;
  bool get hasStreakBonus => longestStreak >= 3;

  // ✅ JSON support
  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'topicId': topicId,
        'total': total,
        'correct': correct,
        'starsEarned': starsEarned,
        'completedAt': completedAt.toIso8601String(),
        'timeSpentSeconds': timeSpentSeconds,
        'longestStreak': longestStreak,
        'timeoutOccurred': timeoutOccurred,
      };

  @override
  String toString() => 'QuizAttemptResult('
      'correct: $correct/$total, '
      'stars: $starsEarned, '
      'time: ${timeSpentSeconds}s, '
      'streak: $longestStreak)';
}
