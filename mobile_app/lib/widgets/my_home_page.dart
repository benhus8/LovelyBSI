import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/question_card.dart';

import '../models/question.dart';
import '../repositories/question_repository.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Question>> _questions;
  bool _showStarred = false;
  bool _isTestMode = false; // Flaga dla trybu Test
  int _currentPage = 0;
  final int _questionsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = QuestionRepository().loadQuestions();
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _goToNextPage(int totalQuestions) {
    if ((_currentPage + 1) * _questionsPerPage < totalQuestions) {
      setState(() {
        _currentPage++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  _isTestMode = value == "Test";
                  _currentPage = 0;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              _showStarred ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              setState(() {
                _showStarred = !_showStarred;
                _currentPage = 0;
                _loadQuestions();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final questions = snapshot.data!.where((q) {
              return _showStarred ? q.isStarred : true;
            }).toList();
            final startIndex = _currentPage * _questionsPerPage;
            final endIndex = startIndex + _questionsPerPage;
            final paginatedQuestions = questions.sublist(
              startIndex,
              endIndex > questions.length ? questions.length : endIndex,
            );

            return Column(
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
                      child: const Text('Poprzednia'),
                    ),
                    Text(
                      'Strona ${_currentPage + 1} z ${(questions.length / _questionsPerPage).ceil()}',
                    ),
                    ElevatedButton(
                      onPressed: ((_currentPage + 1) * _questionsPerPage < questions.length)
                          ? () => _goToNextPage(questions.length)
                          : null,
                      child: const Text('Następna'),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: Text('No questions available.'));
          }
        },
      ),
    );
  }
}
