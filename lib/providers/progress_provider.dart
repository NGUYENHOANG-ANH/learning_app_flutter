import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_progress_model.dart';
import '../models/topic_model.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_model.dart';

// ============= USER PROGRESS PROVIDER =============
final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgress>((ref) {
  return UserProgressNotifier();
});

class UserProgressNotifier extends StateNotifier<UserProgress> {
  UserProgressNotifier()
      : super(
          UserProgress(
            userId: 'child_001',
            topicProgress: {},
            totalStars: 0,
            lastAccessedTime: DateTime.now(),
            unlockedAchievements: [],
          ),
        ) {
    _loadProgress();
  }

  /// Load progress from Hive storage
  Future<void> _loadProgress() async {
    try {
      final storageService = StorageService();
      final savedProgress = await storageService.getProgress();

      if (savedProgress != null) {
        state = savedProgress;
      }
    } catch (e) {
      print('Error loading progress: $e');
      // Keep default state if load fails
    }
  }

  /// Save progress to Hive storage
  Future<void> _saveProgress() async {
    try {
      final storageService = StorageService();
      await storageService.saveProgress(state);
    } catch (e) {
      print('Error saving progress:  $e');
    }
  }

  /// Add stars to a topic and update total
  void addStars(String topicId, int starsToAdd) {
    final currentProgress = state.topicProgress[topicId];

    // Create new TopicProgress with updated stars
    final newTopicProgress = TopicProgress(
      topicId: topicId,
      starsEarned: (currentProgress?.starsEarned ?? 0) + starsToAdd,
      levelProgress: currentProgress?.levelProgress ?? {},
      flashcardsReviewed: currentProgress?.flashcardsReviewed ?? 0,
      lastCompletedTime: DateTime.now(),
    );

    // Update the map (FIX: use topicId as key, not as value)
    final updatedTopicMap = {
      ...state.topicProgress,
      topicId: newTopicProgress, // This was the bug!
    };

    // Update state
    state = state.copyWith(
      topicProgress: updatedTopicMap,
      totalStars: state.totalStars + starsToAdd,
      lastAccessedTime: DateTime.now(),
    );

    // Save to Hive
    _saveProgress();
  }

  /// Update flashcards reviewed count for a topic
  void updateFlashcardsReviewed(String topicId, int count) {
    final currentProgress = state.topicProgress[topicId];

    final newTopicProgress = TopicProgress(
      topicId: topicId,
      starsEarned: currentProgress?.starsEarned ?? 0,
      levelProgress: currentProgress?.levelProgress ?? {},
      flashcardsReviewed: count,
      lastCompletedTime: DateTime.now(),
    );

    final updatedTopicMap = {
      ...state.topicProgress,
      topicId: newTopicProgress,
    };

    state = state.copyWith(topicProgress: updatedTopicMap);

    // Save to Hive
    _saveProgress();
  }

  /// Update quiz level progress
  void updateLevelProgress(
    String topicId,
    String level,
    int score,
  ) {
    final currentProgress = state.topicProgress[topicId];
    final currentLevelProgress = currentProgress?.levelProgress ?? {};

    final newLevelProgress = {
      ...currentLevelProgress,
      level: score,
    };

    final newTopicProgress = TopicProgress(
      topicId: topicId,
      starsEarned: currentProgress?.starsEarned ?? 0,
      levelProgress: newLevelProgress,
      flashcardsReviewed: currentProgress?.flashcardsReviewed ?? 0,
      lastCompletedTime: DateTime.now(),
    );

    final updatedTopicMap = {
      ...state.topicProgress,
      topicId: newTopicProgress,
    };

    state = state.copyWith(topicProgress: updatedTopicMap);

    // Save to Hive
    _saveProgress();
  }

  /// Reset all progress (for debug/settings)
  Future<void> resetProgress() async {
    state = UserProgress(
      userId: 'child_001',
      topicProgress: {},
      totalStars: 0,
      lastAccessedTime: DateTime.now(),
      unlockedAchievements: [],
    );

    await _saveProgress();
  }
}

// ============= TOPICS PROVIDER =============
final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return await DataService().loadTopics();
});

// ============= FLASHCARDS PROVIDER =============
final flashcardsProvider =
    FutureProvider.family<List<Flashcard>, String>((ref, topicId) async {
  return await DataService().loadFlashcardsForTopic(topicId);
});

// ============= QUIZZES PROVIDER =============
final quizzesProvider =
    FutureProvider.family<List<Quiz>, String>((ref, topicId) async {
  return await DataService().loadQuizzesForTopic(topicId);
});
