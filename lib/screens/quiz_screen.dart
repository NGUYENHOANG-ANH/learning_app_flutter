import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/quiz_model.dart';
import '../models/quiz_attempt_result.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/celebration_animation.dart';
import '../widgets/encouragement_message.dart';
import '../widgets/quiz_question_renderer.dart';
import '../widgets/quiz_timer.dart';
import '../services/audio_service.dart';
import '../services/tts_quiz_service.dart';
import '../services/data_service.dart';
import '../services/quiz_shuffler.dart';
import 'result_screen.dart';
import '../providers/progress_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Topic topic;

  const QuizScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _starsEarned = 0;
  bool _answered = false;
  String? _selectedAnswerId;
  bool _isCorrect = false;
  late final AudioService _audioService;
  late final TTSQuizService _ttsService;
  late Future<List<Quiz>> _quizzesFuture;

  // Time + Streak tracking
  int _timeSpentSeconds = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  bool _timeoutOccurred = false;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _audioService.initialize();

    _ttsService = TTSQuizService();
    _ttsService.initialize();

    _quizzesFuture = DataService()
        .loadQuizzesForTopic(widget.topic.id)
        .then((quizzes) => QuizShuffler.shuffleAll(quizzes));
  }

  @override
  void dispose() {
    _audioService.stop();
    _ttsService.stop();
    super.dispose();
  }

  void _handleAnswer(String optionId, List<Quiz> quizzes) {
    if (_answered) return;

    final quiz = quizzes[_currentQuestionIndex];
    final isCorrect = optionId == quiz.correctAnswerId;

    setState(() {
      _answered = true;
      _selectedAnswerId = optionId;
      _isCorrect = isCorrect;

      if (isCorrect) {
        _starsEarned++;
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
        debugPrint('✅ Streak: $_currentStreak (Max: $_longestStreak)');
      } else {
        _currentStreak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        if (isCorrect) {
          _showCelebration();
        } else {
          _showEncouragement();
        }
      }
    });
  }

  void _showCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: CelebrationAnimation(
          message: '🎉 Tuyệt vời! ',
          subtitle: 'Con trả lời đúng!   ',
          stars: 1,
          onDismiss: () {
            Navigator.pop(context);
            _nextQuestion();
          },
        ),
      ),
    );
  }

  void _showEncouragement() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: EncouragementMessage(
          message: '💪 Cố lên! ',
          subtitle: 'Thử lại nhé, con sẽ làm tốt mà!  ',
          onDismiss: () {
            Navigator.pop(context);
            _nextQuestion();
          },
        ),
      ),
    );
  }

  void _nextQuestion() {
    _quizzesFuture.then((quizzes) {
      if (_currentQuestionIndex < quizzes.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
          _selectedAnswerId = null;
        });
      } else {
        _showQuizCompleted(quizzes);
      }
    });
  }

  void _handleTimeout(List<Quiz> quizzes) {
    if (!_answered) {
      setState(() {
        _timeoutOccurred = true;
        _currentStreak = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏰ Hết thời gian!   Chuyển sang câu tiếp theo... '),
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _nextQuestion();
        }
      });
    }
  }

  void _showQuizCompleted(List<Quiz> quizzes) async {
    final result = QuizAttemptResult(
      quizId: quizzes.first.id,
      topicId: widget.topic.id,
      total: quizzes.length,
      correct: _starsEarned,
      completedAt: DateTime.now(),
      timeSpentSeconds: _timeSpentSeconds,
      longestStreak: _longestStreak,
      timeoutOccurred: _timeoutOccurred,
    );

    if (!mounted) return;

    final progressNotifier = ref.read(userProgressProvider.notifier);
    progressNotifier.addStars(widget.topic.id, result.starsEarned);

    debugPrint('✅ Quiz Completed:  ');
    debugPrint('  - Topic: ${widget.topic.id}');
    debugPrint('  - Score: ${result.correct}/${result.total}');
    debugPrint('  - Stars:   ${result.starsEarned}');
    debugPrint('  - Time: ${result.timeSpentSeconds}s');
    debugPrint('  - Longest Streak:  ${result.longestStreak}');

    final shouldRetry = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          topicId: widget.topic.id,
          result: result,
          topic: widget.topic,
        ),
      ),
    );

    if (shouldRetry == 'retry' && mounted) {
      setState(() {
        _currentQuestionIndex = 0;
        _starsEarned = 0;
        _answered = false;
        _selectedAnswerId = null;
        _currentStreak = 0;
        _longestStreak = 0;
        _timeSpentSeconds = 0;
        _timeoutOccurred = false;
      });

      _quizzesFuture = DataService()
          .loadQuizzesForTopic(widget.topic.id)
          .then((quizzes) => QuizShuffler.shuffleAll(quizzes));
    }
  }

  /// ✅ Handle audio question with TTS
  void _handleAudioQuestion(Quiz quiz) async {
    try {
      if (quiz.useTTS && quiz.ttsText != null) {
        // ✅ Use TTS (like flashcard)
        await _ttsService.speakQuizWord(
          word: quiz.ttsText!,
          speed: quiz.ttsSpeed ?? 0.8,
          language: quiz.ttsLanguage ?? 'en-US',
        );
        debugPrint('🎤 Playing TTS: ${quiz.ttsText}');
      } else if (quiz.audioUrl != null && quiz.audioUrl!.isNotEmpty) {
        // Fallback:   use audio file if available
        await _audioService.playAudio(quiz.audioUrl!);
        debugPrint('🔊 Playing audio file: ${quiz.audioUrl}');
      }
    } catch (e) {
      debugPrint('❌ Audio error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi phát âm: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicColor =
        Color(int.parse(widget.topic.color.replaceFirst('#', '0xff')));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        backgroundColor: topicColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Quiz>>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          final quizzes = snapshot.data ?? [];

          if (quizzes.isEmpty) {
            return const Center(
              child: Text('Không có quizzes'),
            );
          }

          final quiz = quizzes[_currentQuestionIndex];
          final hasTimeLimit = quiz.timeLimit != null && quiz.timeLimit! > 0;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Câu ${_currentQuestionIndex + 1} / ${quizzes.length}',
                        style: AppTextStyles.heading3,
                      ),
                      Row(
                        children: [
                          const Text('⭐ ', style: TextStyle(fontSize: 20)),
                          Text(
                            '$_starsEarned',
                            style: AppTextStyles.heading3,
                          ),
                        ],
                      ),
                      if (hasTimeLimit)
                        QuizTimer(
                          totalSeconds: quiz.timeLimit!,
                          onTimeUp: () => _handleTimeout(quizzes),
                          onTick: (remaining) {
                            setState(() {
                              _timeSpentSeconds = quiz.timeLimit! - remaining;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (_currentQuestionIndex + 1) / quizzes.length,
                      child: Container(
                        decoration: BoxDecoration(
                          color: topicColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(quiz.level).withOpacity(0.2),
                      border: Border.all(
                        color: _getDifficultyColor(quiz.level),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getDifficultyLabel(quiz.level),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getDifficultyColor(quiz.level),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          quiz.question,
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // ✅ FIX: Audio button for listening questions
                        if (quiz.questionType == QuestionType.audio)
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () => _handleAudioQuestion(quiz),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: topicColor.withOpacity(0.1),
                                    border: Border.all(
                                      color: topicColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.volume_up,
                                        color: topicColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _ttsService.isPlaying
                                            ? '🎤 Đang phát..  .'
                                            : '🎤 Nhấn để nghe',
                                        style: AppTextStyles.heading3.copyWith(
                                          color: topicColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          )
                        else
                          // ✅ FIX:  Convert QuestionType enum to string
                          QuizQuestionRenderer.renderQuestion(
                            questionType:
                                quiz.questionType.toString().split('.').last,
                            imageUrl: quiz.imageUrl,
                            audioUrl: quiz.audioUrl,
                            question: '',
                            onAudioTap: quiz.audioUrl != null &&
                                    quiz.audioUrl!.isNotEmpty
                                ? () async {
                                    await _audioService
                                        .playAudio(quiz.audioUrl!);
                                  }
                                : null,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentStreak > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.correctGreen.withOpacity(0.2),
                          border: Border.all(
                            color: AppColors.correctGreen,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Streak: $_currentStreak',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.correctGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...quiz.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswerId == option.id;
                    final isCorrectOption = option.id == quiz.correctAnswerId;

                    Color buttonColor = AppColors.cardBackground;
                    Color borderColor = Colors.grey[300]!;
                    Color textColor = AppColors.textPrimary;

                    if (_answered) {
                      if (isSelected && _isCorrect) {
                        buttonColor = AppColors.correctGreen;
                        textColor = Colors.white;
                      } else if (isSelected && !_isCorrect) {
                        buttonColor = AppColors.wrongRed;
                        textColor = Colors.white;
                      } else if (isCorrectOption && !_isCorrect) {
                        buttonColor = AppColors.correctGreen;
                        textColor = Colors.white;
                      }
                    } else if (isSelected) {
                      borderColor = topicColor;
                      buttonColor = topicColor.withOpacity(0.1);
                      textColor = topicColor;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _answered
                            ? null
                            : () => _handleAnswer(option.id, quizzes),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            border: Border.all(
                              color: borderColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: textColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: AppTextStyles.heading3.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Row(
                                  children: [
                                    if (option.imageUrl.isNotEmpty)
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Image.asset(
                                          option.imageUrl,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Center(
                                              child: Text(
                                                option.text[0],
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    if (option.imageUrl.isNotEmpty)
                                      const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        option.text,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: textColor,
                                          fontWeight: _answered
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_answered)
                                Icon(
                                  isCorrectOption
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: Colors.white,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  if (_answered)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: topicColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentQuestionIndex < quizzes.length - 1
                              ? 'Câu tiếp theo'
                              : 'Hoàn thành',
                          style: AppTextStyles.buttonLarge,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return AppColors.correctGreen;
      case 2:
        return Colors.orange;
      case 3:
        return AppColors.wrongRed;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
        return '⭐ Dễ';
      case 2:
        return '⭐⭐ Vừa';
      case 3:
        return '⭐⭐⭐ Khó';
      default:
        return 'Bình thường';
    }
  }
}
