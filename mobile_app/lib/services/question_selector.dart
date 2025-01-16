import 'dart:math';
import '../models/question.dart';
import '../models/question_progress.dart';

class QuestionSelector {
  final Random _random = Random();

  Question selectNextQuestion(
    List<Question> allQuestions,
    Map<int, QuestionProgress> progress,
    List<int> recentQuestionIds,
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
      return _selectWithRecency(unanswered, recentQuestionIds);
    } 
    // 20% chance for wrongly answered
    else if (roll < 0.9 && wronglyAnswered.isNotEmpty) {
      return _selectWithRecency(wronglyAnswered, recentQuestionIds);
    } 
    // 10% chance for correctly answered
    else if (correctlyAnswered.isNotEmpty) {
      return _selectWithRecency(correctlyAnswered, recentQuestionIds);
    }
    
    // Fallback to random question if categories are empty
    return _selectWithRecency(allQuestions, recentQuestionIds);
  }

  Question _selectWithRecency(List<Question> questions, List<int> recentQuestionIds) {
    if (questions.isEmpty) {
      throw Exception("No questions available to select from");
    }

    // Calculate weights based on recency
    final weights = questions.map((question) {
      final index = recentQuestionIds.indexOf(question.questionId);
      if (index == -1) {
        return 1.0; // Not in recent questions, full weight
      } else {
        // Reduce weight based on recency (more recent = lower weight)
        return 1.0 / (index + 2); // +2 to avoid 0 weight
      }
    }).toList();

    // Select a question based on weights
    final selectedIndex = _selectWeightedRandom(weights);
    return questions[selectedIndex];
  }

  int _selectWeightedRandom(List<double> weights) {
    final totalWeight = weights.reduce((a, b) => a + b);
    final randomValue = _random.nextDouble() * totalWeight;

    double cumulativeWeight = 0;
    for (int i = 0; i < weights.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return i;
      }
    }
    return 0; // Fallback, should not happen
  }
} 