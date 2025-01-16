import 'answer.dart';

class Question {
  final int questionId;
  final String title;
  final List<Answer> answers;
  final int clue;
  bool isStarred;
  final String? explanation;
  final List<String>? keyTakeaways;

  Question({
    required this.questionId,
    required this.title,
    required this.answers,
    required this.clue,
    this.isStarred = false,
    this.explanation,
    this.keyTakeaways,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'],
      title: json['title'],
      answers: (json['answers'] as List)
          .map((answer) => Answer.fromJson(answer))
          .toList(),
      clue: json['clue'],
      isStarred: json['isStarred'] ?? false,
      explanation: json['explanation'],
      keyTakeaways: (json['key_takeaways'] as List?)?.map((e) => e as String).toList(),
    );
  }
}