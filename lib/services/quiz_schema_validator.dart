import '../models/validators.dart';

/// ✅ High-level schema validator for quizzes
class QuizSchemaValidator {
  /// Validate all quiz files together
  static Future<Map<String, List<String>>> validateAllQuizzes(
    Map<String, Map<String, dynamic>> allQuizzesMap,
  ) async {
    final results = <String, List<String>>{};

    for (final entry in allQuizzesMap.entries) {
      final topicId = entry.key;
      final quizJson = entry.value;

      final errors = QuizValidator.validateJson(quizJson, topicId);
      if (errors.isNotEmpty) {
        results[topicId] = errors;
      }
    }

    return results;
  }

  /// Print validation results nicely
  static void printValidationResults({
    required String filename,
    required List<String> errors,
    bool verbose = true,
  }) {
    if (errors.isEmpty) {
      print('✅ $filename - VALID');
      return;
    }

    if (!verbose) {
      final criticalCount = errors.where((e) => !e.startsWith('⚠️')).length;
      final warningCount = errors.where((e) => e.startsWith('⚠️')).length;
      print('❌ $filename - $criticalCount critical, $warningCount warnings');
      return;
    }

    print('\n$filename: ');
    for (final error in errors) {
      print('  $error');
    }
  }

  /// Generate validation report
  static String generateReport(
    Map<String, List<String>> validationResults,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('📋 JSON VALIDATION REPORT');
    buffer.writeln('━' * 60);

    int totalErrors = 0;
    int totalWarnings = 0;
    final failedTopics = <String>[];

    for (final entry in validationResults.entries) {
      final topicId = entry.key;
      final errors = entry.value;

      final criticalErrors = errors.where((e) => !e.startsWith('⚠️')).toList();
      final warnings = errors.where((e) => e.startsWith('⚠️')).toList();

      totalErrors += criticalErrors.length;
      totalWarnings += warnings.length;

      if (criticalErrors.isNotEmpty) {
        failedTopics.add(topicId);
      }

      if (errors.isNotEmpty) {
        buffer.writeln('$topicId:');
        for (final error in errors) {
          buffer.writeln('  $error');
        }
      }
    }

    buffer.writeln('\n━' * 60);
    buffer.writeln('Summary:');
    buffer.writeln('  ❌ Critical Errors: $totalErrors');
    buffer.writeln('  ⚠️ Warnings: $totalWarnings');
    buffer.writeln(
        '  ✅ Failed Topics: ${failedTopics.isEmpty ? 'None' : failedTopics.join(", ")}');

    return buffer.toString();
  }
}
