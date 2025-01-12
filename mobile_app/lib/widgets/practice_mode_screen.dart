import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/question_progress.dart';
import '../repositories/progress_repository.dart';
import '../services/question_selector.dart';
import 'progress_indicator_widget.dart';

class PracticeModeScreen extends StatefulWidget {
  final List<Question> questions;
  final bool isReviewMode;

  const PracticeModeScreen({
    Key? key,
    required this.questions,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  _PracticeModeScreenState createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  late Question _currentQuestion;
  final QuestionSelector _selector = QuestionSelector();
  final ProgressRepository _progressRepo = ProgressRepository();
  late Map<int, QuestionProgress> _progress;
  Set<int> _selectedAnswers = {};
  bool _showingResults = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressAndQuestion();
  }

  Future<void> _loadProgressAndQuestion() async {
    setState(() => _isLoading = true);
    _progress = await _progressRepo.loadProgress();
    
    if (widget.isReviewMode && widget.questions.length == 1) {
      _currentQuestion = widget.questions.first;
    } else {
      _loadNextQuestion();
    }
    
    setState(() => _isLoading = false);
  }

  void _onAnswerSelected(int index) {
    if (_showingResults) return;
    
    setState(() {
      if (_selectedAnswers.contains(index)) {
        _selectedAnswers.remove(index);
      } else {
        _selectedAnswers.add(index);
      }
    });
  }

  BoxDecoration _getAnswerDecoration(int index) {
    final isCorrect = _currentQuestion.answers[index].isCorrect;
    final isSelected = _selectedAnswers.contains(index);

    if (!_showingResults) {
      return BoxDecoration(
        color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      );
    }

    Color backgroundColor = Colors.white;
    BoxBorder border = Border.all(color: Colors.grey);

    if (isCorrect) {
      // Correct answer - always show green background
      backgroundColor = Colors.green.withOpacity(0.2);
      
      if (!isSelected) {
        // Correct answer that wasn't selected - add warning border
        border = Border.all(
          color: Colors.amber,
          width: 2.0,
          style: BorderStyle.solid,
        );
      }
    } else if (isSelected) {
      // Wrong selection - show red background
      backgroundColor = Colors.red.withOpacity(0.2);
    }

    return BoxDecoration(
      color: backgroundColor,
      border: border,
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  void _checkAnswers() {
    setState(() {
      _showingResults = true;
      
      // Get correct answer indices
      final correctIndices = _currentQuestion.answers
          .asMap()
          .entries
          .where((e) => e.value.isCorrect)
          .map((e) => e.key)
          .toSet();

      // Update progress
      final questionProgress = _progress[_currentQuestion.questionId] ??
          QuestionProgress(questionId: _currentQuestion.questionId);
      
      questionProgress.updateProgress(_selectedAnswers, correctIndices);
      _progress[_currentQuestion.questionId] = questionProgress;
      
      // Save progress
      _progressRepo.saveProgress(_progress);
    });
  }

  void _loadNextQuestion() {
    if (widget.isReviewMode) {
      // In review mode, we're done after one question
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentQuestion = _selector.selectNextQuestion(
        widget.questions,
        _progress,
      );
      _selectedAnswers = {};
      _showingResults = false;
    });
  }

  Future<void> _resetProgress() async {
    await _progressRepo.resetProgress();
    _loadProgressAndQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final content = Column(
      children: [
        if (!widget.isReviewMode) 
          ProgressIndicatorWidget(
            progress: _progress,
            totalQuestions: widget.questions.length,
            questions: widget.questions,
          ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pytanie ${_currentQuestion.questionId}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentQuestion.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currentQuestion.answers.length,
                      itemBuilder: (context, index) {
                        final answer = _currentQuestion.answers[index];
                        return GestureDetector(
                          onTap: () => _onAnswerSelected(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: _getAnswerDecoration(index),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(answer.text),
                                ),
                                if (_showingResults && _currentQuestion.answers[index].isCorrect)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!widget.isReviewMode)
                        TextButton(
                          onPressed: _resetProgress,
                          child: const Text('Resetuj postęp'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _showingResults ? _loadNextQuestion : _checkAnswers,
                        child: Text(_showingResults 
                          ? (widget.isReviewMode ? 'Powrót do przeglądu' : 'Następne pytanie') 
                          : 'Sprawdź odpowiedzi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isReviewMode) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ćwiczenie pytania'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: content,
      );
    }

    return content;
  }
} 