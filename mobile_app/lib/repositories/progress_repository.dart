import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/question_progress.dart';

class ProgressRepository {
  Future<void> saveProgress(Map<int, QuestionProgress> progress) async {
    final file = await _getProgressFile();
    final data = progress.map((key, value) => MapEntry(key.toString(), value.toJson()));
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<int, QuestionProgress>> loadProgress() async {
    final file = await _getProgressFile();
    
    if (!file.existsSync()) {
      return {};
    }

    final String content = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    
    return data.map((key, value) => MapEntry(
      int.parse(key),
      QuestionProgress.fromJson(value),
    ));
  }

  Future<void> resetProgress() async {
    final file = await _getProgressFile();
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<File> _getProgressFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/question_progress.json');
  }
} 