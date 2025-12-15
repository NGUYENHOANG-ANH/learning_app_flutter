import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// ✅ Quiz timer with visual feedback
class QuizTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback onTimeUp;
  final ValueChanged<int>? onTick;

  const QuizTimer({
    Key? key,
    required this.totalSeconds,
    required this.onTimeUp,
    this.onTick,
  }) : super(key: key);

  @override
  State<QuizTimer> createState() => _QuizTimerState();
}

class _QuizTimerState extends State<QuizTimer> {
  late Timer _timer;
  late int _remainingSeconds;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          widget.onTick?.call(_remainingSeconds);
        } else {
          _timeUp = true;
          _timer.cancel();
          widget.onTimeUp();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Get color based on time remaining
  Color _getTimerColor() {
    final percentage = _remainingSeconds / widget.totalSeconds;

    if (percentage > 0.5) return AppColors.correctGreen; // Green
    if (percentage > 0.25) return Colors.orange; // Orange
    return AppColors.wrongRed; // Red
  }

  /// Format seconds to MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.15),
        border: Border.all(
          color: _getTimerColor(),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            color: _getTimerColor(),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(_remainingSeconds),
            style: AppTextStyles.heading3.copyWith(
              color: _getTimerColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_timeUp)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '⏰ HẾT GIỜ! ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.wrongRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
