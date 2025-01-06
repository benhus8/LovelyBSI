import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionRepository {
  Future<List<Question>> loadQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => Question.fromJson(json)).toList();
  }
}