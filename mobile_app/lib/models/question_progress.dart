import 'dart:collection';

class AttemptResult {
  final Set<int> correctSelections;
  final Set<int> wrongSelections;
  final DateTime timestamp;
  final bool isPerfect;
  final double partialScore;

  AttemptResult({
    required this.correctSelections,
    required this.wrongSelections,
    required this.timestamp,
    required this.isPerfect,
    required this.partialScore,
  });

  factory AttemptResult.fromJson(Map<String, dynamic> json) {
    return AttemptResult(
      correctSelections: Set<int>.from(json['correctSelections'] ?? []),
      wrongSelections: Set<int>.from(json['wrongSelections'] ?? []),
      timestamp: DateTime.parse(json['timestamp']),
      isPerfect: json['isPerfect'],
      partialScore: json['partialScore'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correctSelections': correctSelections.toList(),
      'wrongSelections': wrongSelections.toList(),
      'timestamp': timestamp.toIso8601String(),
      'isPerfect': isPerfect,
      'partialScore': partialScore,
    };
  }
}

class QuestionProgress {
  final int questionId;
  final Queue<AttemptResult> attempts;
  final int maxAttempts = 10; // Keep last N attempts
  
  // Cached values
  double _weightedSuccessRate = 0.0;
  int _perfectAttempts = 0;
  DateTime lastAttempted;

  QuestionProgress({
    required this.questionId,
    Queue<AttemptResult>? attempts,
    DateTime? lastAttempted,
  })  : this.attempts = attempts ?? Queue<AttemptResult>(),
        this.lastAttempted = lastAttempted ?? DateTime.now();

  factory QuestionProgress.fromJson(Map<String, dynamic> json) {
    final attempts = Queue<AttemptResult>.from(
      (json['attempts'] as List? ?? []).map((a) => AttemptResult.fromJson(a))
    );
    
    final progress = QuestionProgress(
      questionId: json['questionId'],
      attempts: attempts,
      lastAttempted: DateTime.parse(json['lastAttempted']),
    );
    
    progress._recalculateStats();
    return progress;
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'attempts': attempts.toList().map((a) => a.toJson()).toList(),
      'lastAttempted': lastAttempted.toIso8601String(),
    };
  }

  void _recalculateStats() {
    if (attempts.isEmpty) {
      _weightedSuccessRate = 0.0;
      _perfectAttempts = 0;
      return;
    }

    // Calculate weighted success rate
    double totalWeight = 0;
    double weightedSum = 0;
    _perfectAttempts = 0;

    final attemptsList = attempts.toList();
    for (int i = 0; i < attemptsList.length; i++) {
      final attempt = attemptsList[i];
      final weight = (i + 1) / attemptsList.length; // More recent attempts have higher weight
      
      weightedSum += attempt.partialScore * weight;
      totalWeight += weight;
      
      if (attempt.isPerfect) _perfectAttempts++;
    }

    _weightedSuccessRate = weightedSum / totalWeight;
  }

  void updateProgress(Set<int> selectedAnswers, Set<int> actualCorrectAnswers) {
    final correctSelections = selectedAnswers.where(
      (i) => actualCorrectAnswers.contains(i)
    ).toSet();
    
    final wrongSelections = selectedAnswers.where(
      (i) => !actualCorrectAnswers.contains(i)
    ).toSet();

    // Calculate partial score
    final maxPossibleScore = actualCorrectAnswers.length;
    final wrongPenalty = wrongSelections.length * 0.5; // Each wrong answer reduces score by 0.5
    final partialScore = (correctSelections.length - wrongPenalty) / maxPossibleScore;
    
    // Check if the answer was perfect
    final isPerfect = correctSelections.length == actualCorrectAnswers.length && 
                     wrongSelections.isEmpty;

    // Create new attempt
    final attempt = AttemptResult(
      correctSelections: correctSelections,
      wrongSelections: wrongSelections,
      timestamp: DateTime.now(),
      isPerfect: isPerfect,
      partialScore: partialScore.clamp(0.0, 1.0),
    );

    // Add attempt and maintain queue size
    attempts.addLast(attempt);
    while (attempts.length > maxAttempts) {
      attempts.removeFirst();
    }

    lastAttempted = attempt.timestamp;
    _recalculateStats();
  }

  // Getters for stats
  int get timesAttempted => attempts.length;
  double get successRate => _weightedSuccessRate;
  int get perfectAttempts => _perfectAttempts;
  bool get hasRecentPerfectAttempt => 
    attempts.isNotEmpty && attempts.last.isPerfect;
  
  // Helper method to determine if question needs review
  bool get needsReview => 
    _weightedSuccessRate < 0.7 || // Less than 70% weighted success
    attempts.isEmpty || // Never attempted
    (!hasRecentPerfectAttempt && timesAttempted < 3); // No recent perfect attempt and few tries
} 