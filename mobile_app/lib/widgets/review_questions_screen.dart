import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_progress.dart';
import 'practice_mode_screen.dart';

class ReviewQuestionsScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<int, QuestionProgress> progress;

  const ReviewQuestionsScreen({
    Key? key,
    required this.questions,
    required this.progress,
  }) : super(key: key);

  List<Question> _getQuestionsToReview() {
    final questionsToReview = questions.where((q) {
      final progress = this.progress[q.questionId];
      return progress != null && progress.successRate < 0.7;
    }).toList();
    
    // Sort by success rate (worst first)
    questionsToReview.sort((a, b) {
      final rateA = progress[a.questionId]?.successRate ?? 0.0;
      final rateB = progress[b.questionId]?.successRate ?? 0.0;
      return rateA.compareTo(rateB);
    });
    
    return questionsToReview;
  }

  @override
  Widget build(BuildContext context) {
    final questionsToReview = _getQuestionsToReview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pytania do powtórki'),
      ),
      body: questionsToReview.isEmpty
          ? const Center(
              child: Text('Brak pytań do powtórki!'),
            )
          : ListView.builder(
              itemCount: questionsToReview.length,
              itemBuilder: (context, index) {
                final question = questionsToReview[index];
                final questionProgress = progress[question.questionId]!;
                
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    title: Text(question.title),
                    subtitle: Text(
                      'Skuteczność: ${(questionProgress.successRate * 100).toStringAsFixed(1)}%\n'
                      'Próby: ${questionProgress.timesAttempted}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PracticeModeScreen(
                              questions: [question],
                              isReviewMode: true,
                              key: ValueKey('practice_${question.questionId}'),
                            ),
                          ),
                        );
                      },
                      child: const Text('Ćwicz'),
                    ),
                  ),
                );
              },
            ),
    );
  }
} 