import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String langCode;
  final String module;
  final String submodule;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.langCode,
    required this.module,
    required this.submodule,
  });

  int _calculateStars(double percentage) {
    if (percentage >= 90) return 5;
    if (percentage >= 75) return 4;
    if (percentage >= 60) return 3;
    if (percentage >= 40) return 2;
    return 1;
  }

  String _feedback(double percentage, AppLocalizations loc) {
    if (percentage >= 90) return loc.outstanding;
    if (percentage >= 75) return loc.greatJob;
    if (percentage >= 50) return loc.goodEffort;
    return loc.tryAgain;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    double percentage = total > 0 ? (score / total) * 100 : 0;
    int stars = _calculateStars(percentage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(loc.quizResults),
        backgroundColor: Colors.orange,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    size: 42,
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Score
              Text(
                '$score / $total',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              // Percentage
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // Progress bar
              LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.orange.shade100,
                valueColor: const AlwaysStoppedAnimation(Colors.green),
              ),
              const SizedBox(height: 28),
              // Feedback message
              Text(
                _feedback(percentage, loc),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Restart and Home buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.replay),
                    label: Text(loc.restartQuiz),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/questions',
                        arguments: {
                          'langCode': langCode,
                          'level': 1,
                          'module': module,
                          'submodule': submodule,
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 18),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: Text(loc.homeButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      side: const BorderSide(color: Colors.orange, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
