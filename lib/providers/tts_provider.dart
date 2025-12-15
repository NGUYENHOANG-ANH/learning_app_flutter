import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS Provider - Quản lý trạng thái phát âm
final ttsProvider = StateNotifierProvider<TtsNotifier, TtsState>((ref) {
  return TtsNotifier();
});

class TtsState {
  final bool isPlaying;
  final String? currentWordId; // ID flashcard đang phát
  final double playbackRate;

  TtsState({
    this.isPlaying = false,
    this.currentWordId,
    this.playbackRate = 0.5,
  });

  TtsState copyWith({
    bool? isPlaying,
    String? currentWordId,
    double? playbackRate,
  }) {
    return TtsState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentWordId: currentWordId ?? this.currentWordId,
      playbackRate: playbackRate ?? this.playbackRate,
    );
  }
}

class TtsNotifier extends StateNotifier<TtsState> {
  final FlutterTts _tts = FlutterTts();

  TtsNotifier() : super(TtsState()) {
    _initTts();
  }

  void _initTts() async {
    try {
      // ✅ Set language - Tiếng Anh US
      await _tts.setLanguage('en-US');

      // ✅ Set pitch & rate - Phù hợp cho trẻ em
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5); // Chậm 1 chút

      // ✅ Listen to completion event
      _tts.setCompletionHandler(() {
        state = state.copyWith(isPlaying: false, currentWordId: null);
      });

      // ✅ Listen to error
      _tts.setErrorHandler((msg) {
        print('🔴 TTS Error: $msg');
        state = state.copyWith(isPlaying: false, currentWordId: null);
      });
    } catch (e) {
      print('🔴 TTS Init Error: $e');
    }
  }

  /// ✅ Phát âm từ hoặc IPA
  Future<void> speak(String text, String wordId) async {
    try {
      // Nếu đang phát từ khác, dừng trước
      if (state.isPlaying && state.currentWordId != wordId) {
        await stop();
      }

      if (!state.isPlaying) {
        state = state.copyWith(isPlaying: true, currentWordId: wordId);
        await _tts.speak(text);
      }
    } catch (e) {
      print('🔴 Error speaking: $e');
      state = state.copyWith(isPlaying: false, currentWordId: null);
    }
  }

  /// ✅ Dừng phát âm
  Future<void> stop() async {
    try {
      await _tts.stop();
      state = state.copyWith(isPlaying: false, currentWordId: null);
    } catch (e) {
      print('🔴 Error stopping TTS: $e');
    }
  }

  /// ✅ Tạm dừng
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (e) {
      print('🔴 Error pausing TTS: $e');
    }
  }

  /// ✅ Set tốc độ phát âm
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
      state = state.copyWith(playbackRate: rate);
    } catch (e) {
      print('🔴 Error setting speech rate: $e');
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
