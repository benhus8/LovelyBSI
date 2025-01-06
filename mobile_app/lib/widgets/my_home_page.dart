import 'package:flutter/material.dart';

import '../models/question.dart';
import '../repositories/question_repository.dart';
import '../widgets/question_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Question> _allQuestions = [];
  late List<Question> _filteredQuestions =
      [];
  bool _showStarred = false;
  bool _isTestMode = false;
  int _currentPage = 0;
  final int _questionsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await QuestionRepository().loadQuestions();
    setState(() {
      _allQuestions = questions;
      _filterQuestions();
    });
  }

  void _filterQuestions() {
    _filteredQuestions = _allQuestions.where((q) {
      return _showStarred ? q.isStarred : true;
    }).toList();
    _currentPage = 0;
  }

  void _toggleStarred() {
    setState(() {
      _showStarred = !_showStarred;
      _filterQuestions();
    });

  }

  void _changeMode(String mode) {
    setState(() {
      _isTestMode = mode == "Test";
      _filterQuestions();
    });
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage() {
    if ((_currentPage + 1) * _questionsPerPage < _filteredQuestions.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  int _getStartQuestionNumber() {
    return _currentPage * _questionsPerPage + 1;
  }

  int _getEndQuestionNumber() {
    final end = (_currentPage + 1) * _questionsPerPage;
    return end > _filteredQuestions.length ? _filteredQuestions.length : end;
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * _questionsPerPage;
    final endIndex = startIndex + _questionsPerPage;
    final paginatedQuestions = _filteredQuestions.sublist(
      startIndex,
      endIndex > _filteredQuestions.length
          ? _filteredQuestions.length
          : endIndex,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButton<String>(
            value: _isTestMode ? "Test" : "Nauka",
            items: const [
              DropdownMenuItem(value: "Nauka", child: Text("Nauka")),
              DropdownMenuItem(value: "Test", child: Text("Test")),
            ],
            onChanged: (String? value) {
              if (value != null) {
                _changeMode(value);
              }
            },
          ),
          IconButton(
            icon: Icon(
              _showStarred ? Icons.star : Icons.star_border,
            ),
            onPressed: _toggleStarred,
          ),
        ],
      ),
      body: _filteredQuestions.isNotEmpty
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: paginatedQuestions.length,
                    itemBuilder: (context, index) {
                      return QuestionCard(
                        question: paginatedQuestions[index],
                        isTestMode: _isTestMode,
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                      child: const Text('⬅️'),
                    ),
                    Text(
                      'Pytania ${_getStartQuestionNumber()}-${_getEndQuestionNumber()} z ${_filteredQuestions.length}',
                    ),
                    ElevatedButton(
                      onPressed: ((_currentPage + 1) * _questionsPerPage <
                              _filteredQuestions.length)
                          ? _goToNextPage
                          : null,
                      child: const Text('➡️'),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: Text('Brak pytań do wyświetlenia.')),
    );
  }
}
