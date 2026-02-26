import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'flashcard_screen.dart';

class FlashcardTutorialScreen extends StatefulWidget {
  final Topic topic;

  const FlashcardTutorialScreen({
    super.key,
    required this.topic,
  });

  @override
  State<FlashcardTutorialScreen> createState() =>
      _FlashcardTutorialScreenState();
}

class _FlashcardTutorialScreenState extends State<FlashcardTutorialScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _flipController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _goToFlashcards();
    }
  }

  /// ✅ FIXED NAVIGATION
  void _goToFlashcards() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardScreen(
          topicId: widget.topic.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topicColor =
        Color(int.parse(widget.topic.color.replaceFirst('#', '0xff')));

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Hướng dẫn Flashcard"),
        backgroundColor: topicColor,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 4,
            minHeight: 8,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Text(
                "Bước ${_currentStep + 1}",
                style: AppTextStyles.heading1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _nextStep,
              child: Text(_currentStep < 3 ? "Tiếp tục" : "Bắt đầu học"),
            ),
          )
        ],
      ),
    );
  }
}
