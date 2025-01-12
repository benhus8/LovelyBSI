import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_progress.dart';
import 'review_questions_screen.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final Map<int, QuestionProgress> progress;
  final int totalQuestions;
  final List<Question> questions;

  const ProgressIndicatorWidget({
    Key? key,
    required this.progress,
    required this.totalQuestions,
    required this.questions,
  }) : super(key: key);

  double _calculateAverageSuccess() {
    if (progress.isEmpty) return 0.0;
    final total = progress.values
        .map((p) => p.successRate)
        .reduce((a, b) => a + b);
    return total / progress.length;
  }

  Color _getColorForProgress(double value) {
    if (value < 0.4) return Colors.red;
    if (value < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final averageSuccess = _calculateAverageSuccess();
    final questionsToReview = progress.values.where((p) => p.successRate < 0.7).length;
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress.length / totalQuestions,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForProgress(averageSuccess),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Pytania', '${progress.length}/$totalQuestions', null),
                _buildStat('Skuteczność', 
                  '${(averageSuccess * 100).toStringAsFixed(1)}%', null),
                _buildStat(
                  'Do powtórki', 
                  '$questionsToReview',
                  questionsToReview > 0 ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ReviewQuestionsScreen(
                          questions: questions,
                          progress: progress,
                        ),
                      ),
                    );
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, VoidCallback? onTap) {
    final content = Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        if (onTap != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.blue,
                ),
              ],
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );

    if (onTap != null) {
      return Tooltip(
        message: 'Kliknij aby zobaczyć pytania do powtórki',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: content,
        ),
      );
    }

    return content;
  }
} 