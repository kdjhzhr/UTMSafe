import 'package:flutter/material.dart';

class SafetyQuizPage extends StatefulWidget {
  const SafetyQuizPage({super.key});

  @override
  _SafetyQuizPageState createState() => _SafetyQuizPageState();
}

class _SafetyQuizPageState extends State<SafetyQuizPage> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What should you do if you see smoke coming from an electrical outlet?',
      'options': [
        'Pour water on it',
        'Call an electrician immediately',
        'Turn off the main power and unplug devices',
        'Ignore it'
      ],
      'correct': 2,
    },
    {
      'question': 'Which number should you call in case of a fire emergency?',
      'options': ['911', '112', '999', 'All of the above'],
      'correct': 3,
    },
    {
      'question': 'What is the first step in CPR (Cardiopulmonary Resuscitation)?',
      'options': [
        'Call for help',
        'Check if the person is breathing',
        'Start chest compressions',
        'Give mouth-to-mouth ventilation'
      ],
      'correct': 1,
    },
    {
      'question': 'Which of the following is NOT a safe action during an earthquake?',
      'options': [
        'Take cover under a sturdy table',
        'Run outside immediately',
        'Stay away from windows',
        'Drop, Cover, and Hold On'
      ],
      'correct': 1,
    },
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  String _getUserLevel() {
    final percentage = (_score / _questions.length) * 100;
    if (percentage == 100) return 'Safety Expert';
    if (percentage >= 75) return 'Safety Pro';
    if (percentage >= 50) return 'Safety Learner';
    return 'Safety Newbie';
  }

  void _checkAnswer(int selectedOption) {
    setState(() {
      _isCorrect = selectedOption == _questions[_currentQuestionIndex]['correct'];
      if (_isCorrect) _score++;
      _showFeedback = true;
    });
  }

  void _nextQuestionOrFinish() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showFeedback = false;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            score: _score,
            questions: _questions,
            userLevel: _getUserLevel(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safety Quiz',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF5E9D4),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              question['options'].length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: const BorderSide(color: Color(0xFF8B0000)),
                    ),
                  ),
                  onPressed: _showFeedback ? null : () => _checkAnswer(index),
                  child: Text(question['options'][index]),
                ),
              ),
            ),
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _isCorrect
                      ? 'Correct!'
                      : 'Wrong! The correct answer is: ${question['options'][question['correct']]}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            if (_showFeedback)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: _nextQuestionOrFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1 ? 'Next' : 'Finish',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final int score;
  final List<Map<String, dynamic>> questions;
  final String userLevel;

  const QuizResultPage({
    required this.score,
    required this.questions,
    required this.userLevel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: const Color(0xFFF5E9D4),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E9D4), Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score & Level Information - Centered
            Center(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Your Score: $score/${questions.length}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Level: $userLevel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Question Results
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${question['question']}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Correct Answer: ${question['options'][question['correct']]}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Restart Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset the quiz state and navigate back to the quiz page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SafetyQuizPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B0000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    'Restart Quiz',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
