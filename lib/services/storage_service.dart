import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_progress_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const String _progressBoxName = 'user_progress';
  static const String _settingsBoxName = 'app_settings';
  static const String _progressKey = 'progress_data';

  /// Initialize Hive
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      print('✅ Hive initialized');
    } catch (e) {
      print('❌ Hive init error: $e');
    }
  }

  /// Save user progress
  Future<void> saveProgress(UserProgress progress) async {
    try {
      final box = await Hive.openBox<String>(_progressBoxName);
      await box.put(_progressKey, jsonEncode(progress.toJson()));
      print('✅ Progress saved to Hive:   ${progress.totalStars}⭐');
    } catch (e) {
      print('❌ Error saving progress: $e');
    }
  }

  /// Load user progress
  Future<UserProgress?> getProgress() async {
    try {
      final box = await Hive.openBox<String>(_progressBoxName);
      final data = box.get(_progressKey);

      if (data != null) {
        final progress = UserProgress.fromJson(
          jsonDecode(data) as Map<String, dynamic>,
        );
        print('✅ Progress loaded from Hive: ${progress.totalStars}⭐');
        return progress;
      }

      return null;
    } catch (e) {
      print('❌ Error loading progress: $e');
      return null;
    }
  }

  /// Save app setting
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      final box = await Hive.openBox<dynamic>(_settingsBoxName);
      await box.put(key, value);
    } catch (e) {
      print('❌ Error saving setting: $e');
    }
  }

  /// Get app setting
  Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    try {
      final box = await Hive.openBox<dynamic>(_settingsBoxName);
      return box.get(key, defaultValue: defaultValue);
    } catch (e) {
      print('❌ Error loading setting: $e');
      return defaultValue;
    }
  }

  /// Clear all data
  Future<void> clearAll() async {
    try {
      await Hive.deleteBoxFromDisk(_progressBoxName);
      await Hive.deleteBoxFromDisk(_settingsBoxName);
      print('✅ All Hive data cleared');
    } catch (e) {
      print('❌ Error clearing storage: $e');
    }
  }
}
