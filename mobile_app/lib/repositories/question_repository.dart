import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/question.dart';
import 'package:http/http.dart' as http;

class QuestionRepository {

  Future<List<Question>> loadQuestionsFromServer() async {
    final url = Uri.parse('server-url');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((json) {
        final question = Question.fromJson(json);
        question.answers.shuffle();
        return question;
      }).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }



  Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = jsonDecode(response);

    final List<int> starredQuestions = await _loadStarredQuestions();

    return data.map((json) {
      final question = Question.fromJson(json);
      question.isStarred = starredQuestions.contains(question.questionId);
      question.answers.shuffle();
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
