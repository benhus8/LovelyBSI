import 'package:flutter/material.dart';
import '../models/question.dart';
import '../repositories/question_repository.dart';
import '../widgets/question_card.dart';
import '../widgets/practice_mode_screen.dart';
import '../services/question_selector.dart';
import '../repositories/progress_repository.dart';
import '../services/event_bus.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

enum AppMode {
  learning,
  test,
  practice
}

class _MainPageState extends State<MainPage> {
  late List<Question> _allQuestions = [];
  late List<Question> _filteredQuestions = [];
  bool _showStarred = false;
  AppMode _currentMode = AppMode.learning;
  int _currentPage = 0;
  final int _questionsPerPage = 10;
  late List<Question> _originalQuestions = [];
  bool _isShuffled = false;

  final ScrollController _scrollController = ScrollController();

  Map<String, int> _pageByMode = {
    "all": 0,
    "starred": 0,
    "test": 0,
    "learning": 0,
  };

  void _saveCurrentPage(String mode) {
    _pageByMode[mode] = _currentPage;
  }

  void _setPageForMode(String mode) {
    _currentPage = _pageByMode[mode] ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    eventBus.onStarToggled.listen(_handleStarToggle);
  }

  @override
  void dispose() {
    eventBus.dispose();
    super.dispose();
  }

  void _handleStarToggle(int questionId) {
    final questionIndex = _allQuestions.indexWhere((q) => q.questionId == questionId);
    if (questionIndex != -1) {
      setState(() {
        _filterQuestions();
      });
      _saveStarredQuestions();
    }
  }

  void _saveStarredQuestions() async {
    await QuestionRepository().saveStarredQuestions(_allQuestions);
  }

  Future<void> _loadQuestions() async {
    final questions = await QuestionRepository().loadQuestions();
    setState(() {
      _allQuestions = questions;
      _originalQuestions = List.from(questions);
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
    _saveCurrentPage(_showStarred ? "starred" : "all");
    setState(() {
      _showStarred = !_showStarred;
      _filterQuestions();
      _setPageForMode(_showStarred ? "starred" : "all");
    });
  }

  void _toggleShuffle() {
    setState(() {
      if (_isShuffled) {
        _allQuestions = List.from(_originalQuestions);
      } else {
        _allQuestions.shuffle();
        for (var question in _allQuestions) {
          question.answers.shuffle();
        }
      }
      _isShuffled = !_isShuffled;
      _filterQuestions();
    });
  }

  void _changeMode(AppMode mode) {
    setState(() {
      _currentMode = mode;
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

  String _getModeDisplayName(AppMode mode) {
    switch (mode) {
      case AppMode.learning:
        return 'Nauka';
      case AppMode.test:
        return 'Test';
      case AppMode.practice:
        return 'Prawo jazdy';
    }
  }

  Widget _buildLearningTestMode() {
    final startIndex = _currentPage * _questionsPerPage;
    final endIndex = startIndex + _questionsPerPage;
    final paginatedQuestions = _filteredQuestions.sublist(
      startIndex,
      endIndex > _filteredQuestions.length
          ? _filteredQuestions.length
          : endIndex,
    );

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: ValueKey(_currentMode),
            controller: _scrollController,
            itemCount: paginatedQuestions.length,
            itemBuilder: (context, index) {
              return QuestionCard(
                question: paginatedQuestions[index],
                isTestMode: _currentMode == AppMode.test,
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
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 5,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            Text(
              'Pytania ${_getStartQuestionNumber()}-${_getEndQuestionNumber()} z ${_filteredQuestions.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 5,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButton<AppMode>(
            value: _currentMode,
            items: AppMode.values.map((mode) => 
              DropdownMenuItem(
                value: mode,
                child: Text(_getModeDisplayName(mode)),
              )
            ).toList(),
            onChanged: (AppMode? value) {
              if (value != null) {
                _changeMode(value);
              }
            },
          ),
          if (_currentMode != AppMode.practice) ...[
            IconButton(
              icon: Icon(
                _showStarred ? Icons.star : Icons.star_border,
              ),
              onPressed: _toggleStarred,
              tooltip: 'Ulubione pytania',
            ),
            IconButton(
              icon: Icon(
                _isShuffled ? Icons.sort : Icons.shuffle,
              ),
              onPressed: _toggleShuffle,
              tooltip: 'Losowa kolejność',
            ),
          ],
          if (_currentMode == AppMode.practice)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildSettingsMenu(),
                );
              },
            ),
        ],
      ),
      body: _allQuestions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _currentMode == AppMode.practice
              ? PracticeModeScreen(
                  questions: _allQuestions,
                  isReviewMode: false,
                  questionSelector: QuestionSelector(),
                  progressRepository: ProgressRepository(),
                )
              : _buildLearningTestMode(),
    );
  }

  Widget _buildSettingsMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Resetuj postęp'),
            onTap: () {
              Navigator.pop(context);
              eventBus.publishResetProgress();
            },
          ),
        ],
      ),
    );
  }
}
