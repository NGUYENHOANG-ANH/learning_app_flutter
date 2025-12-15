import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/topic_model.dart';
import '../models/flashcard_model.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/flashcard_widget.dart';
import 'flashcard_tutorial_screen.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  final Topic topic;
  final bool showTutorial; // ✅ NEW

  const FlashcardScreen({
    Key? key,
    required this.topic,
    this.showTutorial = true, // ✅ NEW
  }) : super(key: key);

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  late Future<List<Flashcard>> _flashcardsFuture;
  bool _tutorialShown = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flashcardsFuture = DataService().loadFlashcardsForTopic(
      widget.topic.id,
      verbose: true,
    );

    // ✅ Show tutorial on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial && !_tutorialShown) {
        _showTutorial();
      }
    });
  }

  void _showTutorial() {
    setState(() => _tutorialShown = true);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💡 Mẹo Nhỏ', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              Text(
                'Ấn vào thẻ để lật ngược và xem video minh họa!  🎥',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '← Vuốt sang để xem thẻ tiếp theo',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPastel,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Đã hiểu'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDetailedTutorial();
                    },
                    child: Text(
                      'Xem chi tiết',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardTutorialScreen(topic: widget.topic),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topicColor = Color(
      int.parse(widget.topic.color.replaceFirst('#', '0xff')),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.name),
        backgroundColor: topicColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // ✅ Add help button
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTutorial,
            tooltip: 'Hướng dẫn',
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder<List<Flashcard>>(
        future: _flashcardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            );
          }

          final flashcards = snapshot.data ?? [];

          if (flashcards.isEmpty) {
            return const Center(child: Text('Không có flashcards'));
          }

          return Column(
            children: [
              // Progress
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thẻ ${_currentIndex + 1} / ${flashcards.length}',
                      style: AppTextStyles.heading3,
                    ),
                    _buildProgressBar(flashcards.length),
                  ],
                ),
              ),

              // Flashcards
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final fc = flashcards[index];
                    return FlashcardWidget(
                      id: fc.id,
                      frontText: fc.word,
                      pronunciation: fc.pronunciation,
                      vietnameseName: fc.vietnameseName ?? '',
                      description: fc.description ?? '',
                      imageUrl: fc.getFullImagePath(),
                      videoPath: fc.getFullVideoPath(),
                      onFlip: () {
                        print('Flipped: ${fc.word}');
                      },
                    );
                  },
                ),
              ),

              // Navigation
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentIndex > 0
                          ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: topicColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _currentIndex < flashcards.length - 1
                          ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tiếp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: topicColor,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    final progress = (_currentIndex + 1) / total;
    return Expanded(
      child: Container(
        height: 8,
        margin: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.starColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
