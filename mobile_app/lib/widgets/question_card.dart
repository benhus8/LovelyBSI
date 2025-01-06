import 'package:flutter/material.dart';
import '../models/answer.dart';
import '../models/question.dart';

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
  bool highlightAnswers = false; // Czy odpowiedzi mają być podświetlone
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
        selectedAnswers.remove(answer); // Usuń zaznaczenie
      } else {
        selectedAnswers.add(answer); // Dodaj zaznaczenie
      }
    });
  }

  Color _getAnswerColor(Answer answer) {
    if (!highlightAnswers) {
      return selectedAnswers.contains(answer)
          ? Colors.grey.withOpacity(0.3) // Zaznaczona odpowiedź
          : Colors.white; // Nie zaznaczona
    }
    if (answer.isCorrect && selectedAnswers.contains(answer)) {
      return Colors.green.withOpacity(0.3); // Zaznaczona poprawna odpowiedź
    } else if (answer.isCorrect && !selectedAnswers.contains(answer)) {
      return Colors.green.withOpacity(0.3); // Nie zaznaczona, ale poprawna
    } else if (!answer.isCorrect && selectedAnswers.contains(answer)) {
      return Colors.red.withOpacity(0.3); // Zaznaczona, ale niepoprawna odpowiedź
    }
    return Colors.white; // Niepoprawna i nie zaznaczona
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
            // Tytuł pytania
            Text(
              widget.question.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Wyświetlenie odpowiedzi
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.question.answers.map((answer) {
                return GestureDetector(
                  onTap: () {
                    if (widget.isTestMode && !highlightAnswers) {
                      _toggleAnswerSelection(answer); // Zaznaczanie odpowiedzi
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: _getAnswerColor(answer), // Kolor zależny od stanu
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
            // Przycisk "Sprawdź" (widoczny tylko w trybie Test)
            if (widget.isTestMode && !highlightAnswers)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    highlightAnswers = true; // Podświetl odpowiedzi
                  });
                },
                child: const Text("Sprawdź"),
              ),
            // Ikona gwiazdki
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  widget.question.isStarred ? Icons.star : Icons.star_border,
                  color: widget.question.isStarred ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
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
