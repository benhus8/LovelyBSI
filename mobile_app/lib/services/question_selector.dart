import 'dart:math';
import '../models/question.dart';
import '../models/question_progress.dart';

class QuestionSelector {
  final Random _random = Random();
  
  Question selectNextQuestion(
    List<Question> allQuestions,
    Map<int, QuestionProgress> progress
  ) {
    final unanswered = allQuestions.where((q) => 
      !progress.containsKey(q.questionId)
    ).toList();
    
    final wronglyAnswered = allQuestions.where((Question q) {
      final successRate = progress[q.questionId]?.successRate ?? 1.0;
      return successRate < 0.7;
    }).toList();
    
    final correctlyAnswered = allQuestions.where((Question q) {
      final successRate = progress[q.questionId]?.successRate ?? 0.0;
      return successRate >= 0.7;
    }).toList();

    final roll = _random.nextDouble();
    
    // 70% chance for unanswered
    if (roll < 0.7 && unanswered.isNotEmpty) {
      return unanswered[_random.nextInt(unanswered.length)];
    } 
    // 20% chance for wrongly answered
    else if (roll < 0.9 && wronglyAnswered.isNotEmpty) {
      return wronglyAnswered[_random.nextInt(wronglyAnswered.length)];
    } 
    // 10% chance for correctly answered
    else if (correctlyAnswered.isNotEmpty) {
      return correctlyAnswered[_random.nextInt(correctlyAnswered.length)];
    }
    
    // Fallback to random question if categories are empty
    return allQuestions[_random.nextInt(allQuestions.length)];
  }
} 