import 'package:flutter/material.dart';

import '../models/question.dart';
import '../repositories/question_repository.dart';
import '../widgets/question_card.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<Question> _allQuestions = [];
  late List<Question> _filteredQuestions =
      [];
  bool _showStarred = false;
  bool _isTestMode = false;
  int _currentPage = 0;
  final int _questionsPerPage = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _saveStarredQuestions() async {
    await QuestionRepository().saveStarredQuestions(_allQuestions);
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

    _saveStarredQuestions();
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
    _scrollToTop();
  }

  void _goToNextPage() {
    if ((_currentPage + 1) * _questionsPerPage < _filteredQuestions.length) {
      setState(() {
        _currentPage++;
      });
    }
    _scrollToTop();
  }

  int _getStartQuestionNumber() {
    return _currentPage * _questionsPerPage + 1;
  }

  int _getEndQuestionNumber() {
    final end = (_currentPage + 1) * _questionsPerPage;
    return end > _filteredQuestions.length ? _filteredQuestions.length : end;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
                    key: ValueKey(_isTestMode),
                    controller: _scrollController,
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
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: ElevatedButton(
                        onPressed: _currentPage > 0 ? _goToPreviousPage : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Pytania ${_getStartQuestionNumber()}-${_getEndQuestionNumber()} z ${_filteredQuestions.length}',
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: ElevatedButton(
                        onPressed: ((_currentPage + 1) * _questionsPerPage < _filteredQuestions.length)
                            ? _goToNextPage
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: Text('Brak pytań do wyświetlenia.')),
    );
  }
}
