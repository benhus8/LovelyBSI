import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';

class QuestionRepository {
  Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = jsonDecode(response);

    final List<int> starredQuestions = await _loadStarredQuestions();

    return data.map((json) {
      final question = Question.fromJson(json);
      question.isStarred = starredQuestions.contains(question.questionId);
      return question;
    }).toList();
  }

  Future<void> saveStarredQuestions(List<Question> questions) async {
    final File file = await _getStarredFile();

    final List<int> starredIds =
    questions.where((q) => q.isStarred).map((q) => q.questionId).toList();

    await file.writeAsString(jsonEncode(starredIds));
  }

  Future<List<int>> _loadStarredQuestions() async {
    final File file = await _getStarredFile();

    if (!file.existsSync()) {
      return [];
    }

    final String content = await file.readAsString();
    return (jsonDecode(content) as List<dynamic>).map((id) => id as int).toList();
  }

  Future<File> _getStarredFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/starred_questions.json');
  }
}
