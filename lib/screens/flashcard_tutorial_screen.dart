import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'flashcard_screen.dart';

class FlashcardTutorialScreen extends StatefulWidget {
  final Topic topic;

  const FlashcardTutorialScreen({
    Key? key,
    required this.topic,
  }) : super(key: key);

  @override
  State<FlashcardTutorialScreen> createState() =>
      _FlashcardTutorialScreenState();
}

class _FlashcardTutorialScreenState extends State<FlashcardTutorialScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _flipController;
  late AnimationController _pulseController;
  bool _cardFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
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
      setState(() {
        _currentStep++;
        _cardFlipped = false;
        _flipController.reset();
      });
    } else {
      // ✅ FIX: Use pushReplacementNamed to avoid back loop
      _goToFlashcards();
    }
  }

  void _flipCard() {
    if (_currentStep == 1) {
      _flipController.forward();
      setState(() {
        _cardFlipped = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _nextStep();
        }
      });
    }
  }

  /// ✅ FIX:  Go to flashcards WITHOUT tutorial next time
  void _goToFlashcards() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(
          topic: widget.topic,
          showTutorial: false, // Don't show tutorial again
        ),
      ),
    );
  }

  void _skipTutorial() {
    _goToFlashcards();
  }

  @override
  Widget build(BuildContext context) {
    final topicColor = Color(
      int.parse(widget.topic.color.replaceFirst('#', '0xff')),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Hướng Dẫn Học Flashcard'),
        backgroundColor: topicColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _skipTutorial,
        ),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(topicColor),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Step indicator
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: topicColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentStep + 1}',
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Content based on step
                    if (_currentStep == 0)
                      _buildStep0(topicColor)
                    else if (_currentStep == 1)
                      _buildStep1(topicColor)
                    else if (_currentStep == 2)
                      _buildStep2(topicColor)
                    else
                      _buildStep3(topicColor),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _skipTutorial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Bỏ qua',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: topicColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _currentStep < 3 ? 'Tiếp theo' : 'Bắt đầu học',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 0: Welcome
  Widget _buildStep0(Color topicColor) {
    return Column(
      children: [
        Text(
          'Chào mừng đến với ${widget.topic.name}!',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '📚 Con sẽ học từ vựng qua những thẻ flashcard vui vẻ.  Bố mẹ có biết không?  Mỗi thẻ đều có video hướng dẫn đó!',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: topicColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: topicColor,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                '✨ Điều đặc biệt: ',
                style: AppTextStyles.heading3.copyWith(
                  color: topicColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureItem(
                icon: '📖',
                text: 'Mỗi thẻ có hình ảnh và phát âm tiếng Anh',
                color: topicColor,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                icon: '🎥',
                text: 'Lật thẻ để xem video minh họa',
                color: topicColor,
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                icon: '🎮',
                text: 'Sau đó chơi quiz để ôn tập',
                color: topicColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Step 1: How to flip card
  Widget _buildStep1(Color topicColor) {
    return Column(
      children: [
        Text(
          'Cách sử dụng Flashcard',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Ấn vào thẻ để lật ngược và xem video! ',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),

        // Interactive card demo
        GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _flipController,
            builder: (context, child) {
              final angle = _flipController.value * 3.14159265359;
              final transform = Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle);

              return Transform(
                alignment: Alignment.center,
                transform: transform,
                child: Container(
                  width: 280,
                  height: 320,
                  decoration: BoxDecoration(
                    color: !_cardFlipped ? topicColor : Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: topicColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        !_cardFlipped ? '🍎' : '🎥',
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        !_cardFlipped
                            ? 'Mặt trước\n(Tiếng Anh)'
                            : 'Mặt sau\n(Video)',
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 40),

        // Pulse hint
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.2).animate(_pulseController),
          child: Text(
            '👆 Ấn vào thẻ! ',
            style: AppTextStyles.heading3.copyWith(
              color: topicColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Step 2: Front side explanation
  Widget _buildStep2(Color topicColor) {
    return Column(
      children: [
        Text(
          'Mặt trước - Mặt học',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '🍎',
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 12),
              Text(
                'Apple',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '/ˈæpəl/',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: topicColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '🇻🇳 Tiếng Việt',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: topicColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quả táo',
                      style: AppTextStyles.heading3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '📖 Mô tả',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Một loại trái cây ngon, giàu vitamin',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '📚 Con sẽ thấy:\n• Hình ảnh\n• Từ tiếng Anh\n• Cách phát âm\n• Tiếng Việt\n• Mô tả thêm',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Step 3: Back side explanation
  Widget _buildStep3(Color topicColor) {
    return Column(
      children: [
        Text(
          'Mặt sau - Video minh họa',
          style: AppTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      color: topicColor,
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Video\nMinh Họa',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '🎥 Video sẽ giúp con hiểu rõ hơn về từ vựng',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                '✅ Bạn đã sẵn sàng!',
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bây giờ hãy bắt đầu học flashcard.  Nhớ lật thẻ để xem video nhé!  🎥',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
