import 'package:flutter/material.dart';

class ExplanationDialog extends StatelessWidget {
  final String? explanation;
  final List<String>? keyTakeaways;

  const ExplanationDialog({
    Key? key,
    this.explanation,
    this.keyTakeaways,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wyjaśnienie'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (explanation != null && explanation!.isNotEmpty)
              Text(
                explanation!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (keyTakeaways != null && keyTakeaways!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Kluczowe wnioski:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...keyTakeaways!.map((takeaway) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '- $takeaway',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }
} 