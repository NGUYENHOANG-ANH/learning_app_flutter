import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;

  const QuizScreen({
    super.key,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int? selectedIndex;
  bool answered = false;

  void selectAnswer(int index) {
    if (answered) return;

    setState(() {
      selectedIndex = index;
      answered = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() {
        currentIndex++;
        selectedIndex = null;
        answered = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /// hoàn thành quiz
    if (currentIndex >= widget.questions.length) {
      return const Scaffold(
        body: Center(
          child: Text(
            "🎉 Quiz Completed!",
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    final question = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// progress
            LinearProgressIndicator(
              value: (currentIndex + 1) / widget.questions.length,
              minHeight: 8,
            ),

            const SizedBox(height: 30),

            /// question
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                question["question"],
                key: ValueKey(currentIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// options
            ...List.generate(
              question["options"].length,
              (index) {
                final option = question["options"][index];

                final isCorrect = index == question["answer"];

                Color? color;

                if (answered && index == selectedIndex) {
                  color = isCorrect ? Colors.green : Colors.red;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => selectAnswer(index),
                    child: Text(option),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
