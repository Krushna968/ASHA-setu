import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final List<dynamic>? questions; // Allow passing questions

  const QuizScreen({super.key, required this.title, this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _hasAnswered = false;
  int? _selectedAnswerIndex;

  late final List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions?.cast<Map<String, dynamic>>() ?? [
      {
        'question': 'When should complementary feeding for infants begin?',
        'options': ['After 3 months', 'After 6 months', 'After 9 months', 'After 1 year'],
        'correctAnswer': 1, // After 6 months
      },
      {
        'question': 'Which vaccine is given immediately after birth?',
        'options': ['BCG, OPV-0, Hep-B', 'DPT, Polio', 'Measles, Rubella', 'Rotavirus'],
        'correctAnswer': 0,
      },
      {
        'question': 'How many minimum ANC check-ups are recommended during pregnancy?',
        'options': ['2', '3', '4', '6'],
        'correctAnswer': 2, // 4
      }
    ];
  }

  void _checkAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (index == _questions[_currentQuestionIndex]['correctAnswer']) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _hasAnswered = false;
          _selectedAnswerIndex = null;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Completed!'),
        content: Text('You scored $_score out of ${_questions.length}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Finish', style: TextStyle(color: MyTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text("No questions available.")),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: MyTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, color: MyTheme.textDark)),
        backgroundColor: Colors.white,
        centerTitle: false,
        iconTheme: const IconThemeData(color: MyTheme.textDark),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(color: MyTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MyTheme.textDark),
            ),
            const SizedBox(height: 32),
            ...List.generate(question['options'].length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              final isCorrect = index == question['correctAnswer'];
              final showCorrectColor = _hasAnswered && isCorrect;
              final showWrongColor = _hasAnswered && isSelected && !isCorrect;

              Color buttonColor = Colors.white;
              Color textColor = MyTheme.textDark;
              Color borderColor = Colors.grey.shade300;

              if (showCorrectColor) {
                buttonColor = Colors.green.shade100;
                textColor = Colors.green.shade800;
                borderColor = Colors.green;
              } else if (showWrongColor) {
                buttonColor = Colors.red.shade100;
                textColor = Colors.red.shade800;
                borderColor = Colors.red;
              } else if (isSelected) {
                buttonColor = MyTheme.primaryBlue.withValues(alpha: 0.1);
                borderColor = MyTheme.primaryBlue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => _checkAnswer(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      border: Border.all(color: borderColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            question['options'][index],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                        if (showCorrectColor) const Icon(Icons.check_circle, color: Colors.green),
                        if (showWrongColor) const Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
