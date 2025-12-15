import 'package:flutter_tts/flutter_tts.dart';

/// ✅ TTS Service for Quiz listening questions
class TTSQuizService {
  static final TTSQuizService _instance = TTSQuizService._internal();

  factory TTSQuizService() {
    return _instance;
  }

  TTSQuizService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  /// Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _tts.setCompletionHandler(() {
        _isPlaying = false;
        print('✅ TTS completed');
      });

      _isInitialized = true;
      print('✅ TTSQuizService initialized');
    } catch (e) {
      print('❌ TTS init error: $e');
    }
  }

  /// Speak word for quiz listening (like flashcard)
  Future<void> speakQuizWord({
    required String word,
    double speed = 0.8,
    String language = 'en-US',
  }) async {
    try {
      if (!_isInitialized) await initialize();

      // Stop current playback
      if (_isPlaying) {
        await stop();
      }

      // Set language
      await _tts.setLanguage(language);

      // Set speed (0.5 to 2.0)
      await _tts.setSpeechRate(speed.clamp(0.5, 2.0));

      // Speak
      print('🎤 Speaking: $word (speed: $speed, language: $language)');
      await _tts.speak(word);

      _isPlaying = true;
    } catch (e) {
      print('❌ TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isPlaying = false;
      print('⏹️ TTS stopped');
    } catch (e) {
      print('❌ TTS stop error: $e');
    }
  }

  /// Get all available voices
  Future<List<Map>> getVoices() async {
    try {
      final voices = await _tts.getVoices;
      return List<Map>.from(voices);
    } catch (e) {
      print('❌ Error getting voices: $e');
      return [];
    }
  }

  bool get isPlaying => _isPlaying;
}
