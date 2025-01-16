import 'package:flutter/material.dart';
import '../models/answer.dart';
import '../models/question.dart';
import '../services/event_bus.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final bool isTestMode;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.isTestMode,
  }) : super(key: key);

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool highlightAnswers = false;
  final Set<Answer> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    if (!widget.isTestMode) {
      highlightAnswers = true;
    }
  }

  void _toggleAnswerSelection(Answer answer) {
    setState(() {
      if (selectedAnswers.contains(answer)) {
        selectedAnswers.remove(answer);
      } else {
        selectedAnswers.add(answer);
      }
    });
  }

  Color _getAnswerColor(Answer answer) {
    if (!highlightAnswers) {
      return selectedAnswers.contains(answer)
          ? Colors.grey.withOpacity(0.3)
          : Colors.white;
    }
    if (answer.isCorrect && selectedAnswers.contains(answer)) {
      return Colors.green.withOpacity(0.3);
    } else if (answer.isCorrect && !selectedAnswers.contains(answer)) {
      return Colors.green.withOpacity(0.3);
    } else if (!answer.isCorrect && selectedAnswers.contains(answer)) {
      return Colors.red.withOpacity(0.3);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.question.questionId}. ${widget.question.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.question.answers.map((answer) {
                return GestureDetector(
                  onTap: () {
                    if (widget.isTestMode && !highlightAnswers) {
                      _toggleAnswerSelection(answer);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _getAnswerColor(answer),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      answer.text,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (widget.isTestMode && !highlightAnswers)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    highlightAnswers = true;
                  });
                },
                child: const Text("Sprawdź"),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  widget.question.isStarred ? Icons.star : Icons.star_border,
                  color: widget.question.isStarred ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  eventBus.publishStarToggled(widget.question.questionId);
                  setState(() {
                    widget.question.isStarred = !widget.question.isStarred;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
