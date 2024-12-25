import 'package:flutter/material.dart';

class SafetyQuizPage extends StatelessWidget {
  const SafetyQuizPage({super.key});


  @override
  Widget build(BuildContext context) {
    // Categories for the quiz with 5 questions each
    final List<Map<String, dynamic>> quizCategories = [
      {
        'title': 'First Aid Treatment',
        'questions': [
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
            'question': 'How should you treat a burn?',
            'options': [
              'Apply butter or oil',
              'Cool the burn with running water for 10 minutes',
              'Apply ice directly to the burn',
              'Cover it with a blanket'
            ],
            'correct': 1,
          },
          {
            'question': 'If someone is choking, what should you do?',
            'options': [
              'Perform the Heimlich maneuver',
              'Give them water',
              'Slap their back',
              'Do nothing, they will be fine'
            ],
            'correct': 0,
          },
          {
            'question': 'What is the first thing to do in case of a bleeding wound?',
            'options': [
              'Apply pressure to stop the bleeding',
              'Use a tourniquet immediately',
              'Put the person to sleep',
              'Give them something to drink'
            ],
            'correct': 0,
          },
        ],
      },
      {
        'title': 'CPR',
        'questions': [
          {
            'question': 'What is the first step in performing CPR?',
            'options': [
              'Check if the person is breathing',
              'Give chest compressions',
              'Call 911',
              'Administer rescue breaths'
            ],
            'correct': 2,
          },
          {
            'question': 'What is the ratio of chest compressions to rescue breaths?',
            'options': ['30:2', '15:2', '30:1', '60:2'],
            'correct': 0,
          },
          {
            'question': 'How deep should chest compressions be during CPR?',
            'options': [
              '1-2 inches',
              '2-3 inches',
              '3-4 inches',
              '4-5 inches'
            ],
            'correct': 1,
          },
          {
            'question': 'How fast should chest compressions be performed?',
            'options': [
              '100-120 per minute',
              '80-100 per minute',
              '120-140 per minute',
              '150 per minute'
            ],
            'correct': 0,
          },
          {
            'question': 'When should you stop performing CPR?',
            'options': [
              'When the person starts breathing',
              'When professional help arrives',
              'When you are too tired to continue',
              'All of the above'
            ],
            'correct': 3,
          },
        ],
      },
      {
        'title': 'Activities Preparation',
        'questions': [
          {
            'question': 'What is the first thing you should do before an outdoor activity?',
            'options': [
              'Check the weather',
              'Pack a first aid kit',
              'Inform someone about your plans',
              'All of the above'
            ],
            'correct': 3,
          },
          {
            'question': 'How often should you review your emergency preparedness plan?',
            'options': ['Every 6 months', 'Annually', 'Every 3 years', 'Only when an emergency occurs'],
            'correct': 1,
          },
          {
            'question': 'What should be included in an emergency preparedness kit?',
            'options': [
              'Water, food, flashlight, first aid kit',
              'Clothing, cash, and snacks',
              'Only first aid supplies',
              'None of the above'
            ],
            'correct': 0,
          },
          {
            'question': 'Why is it important to have an emergency contact list?',
            'options': [
              'For insurance purposes',
              'To ensure quick communication during an emergency',
              'To track phone usage',
              'None of the above'
            ],
            'correct': 1,
          },
          {
            'question': 'What should you do if you are caught in a snowstorm outdoors?',
            'options': [
              'Find shelter and stay warm',
              'Keep walking to find help',
              'Ignore the storm and continue your activity',
              'Call for help and stay where you are'
            ],
            'correct': 0,
          },
        ],
      },
      {
        'title': 'Mental Health Issues',
        'questions': [
          {
            'question': 'What is a common sign of mental health issues?',
            'options': [
              'Sudden weight loss',
              'Withdrawal from social activities',
              'Excessive talking',
              'Increased energy levels'
            ],
            'correct': 1,
          },
          {
            'question': 'How can you support someone with mental health issues?',
            'options': ['Listen without judgment', 'Encourage them to talk to a professional', 'Both of the above', 'Ignore it'],
            'correct': 2,
          },
          {
            'question': 'What is an effective way to cope with anxiety?',
            'options': [
              'Avoid situations that cause anxiety',
              'Deep breathing exercises',
              'Taking medication without consulting a doctor',
              'Engaging in excessive physical activity'
            ],
            'correct': 1,
          },
          {
            'question': 'Which of the following is NOT a sign of depression?',
            'options': [
              'Feeling hopeless',
              'Loss of interest in activities',
              'Increased energy and enthusiasm',
              'Sleep disturbances'
            ],
            'correct': 2,
          },
          {
            'question': 'What is the first step if you suspect someone is struggling with their mental health?',
            'options': [
              'Confront them aggressively',
              'Ignore it and wait for them to reach out',
              'Encourage them to talk to a mental health professional',
              'Tell others about their issues'
            ],
            'correct': 2,
          },
        ],
      },
      {
        'title': 'Emergency Steps',
        'questions': [
          {
            'question': 'What is the first step in an emergency?',
            'options': [
              'Call 911',
              'Ensure safety',
              'Help the injured',
              'Look for exits'
            ],
            'correct': 1,
          },
          {
            'question': 'What should you do if you are stuck in a building during an emergency?',
            'options': ['Stay calm', 'Look for an escape route', 'Call for help', 'All of the above'],
            'correct': 3,
          },
          {
            'question': 'What should you do if you encounter a fire in a building?',
            'options': [
              'Run out immediately without looking back',
              'Stop, drop, and roll',
              'Call 911 and evacuate carefully',
              'Use a fire extinguisher'
            ],
            'correct': 2,
          },
          {
            'question': 'How should you deal with a person who is unconscious but breathing?',
            'options': [
              'Lay them on their back',
              'Place them in the recovery position',
              'Shake them to wake up',
              'Give them water'
            ],
            'correct': 1,
          },
          {
            'question': 'What is the best way to prepare for natural disasters?',
            'options': [
              'Stay informed about weather conditions',
              'Prepare an emergency kit',
              'Know evacuation routes',
              'All of the above'
            ],
            'correct': 3,
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Color(0xFF8B0000)),
    onPressed: () {
      Navigator.pop(context); // Ensure clean back navigation
    },
  ),
  title: const Text(
    'Quiz Categories',
    style: TextStyle(
      color: Color(0xFF8B0000),
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  backgroundColor: const Color(0xFFF5E9D4),
),

    
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose a Category to Start',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: quizCategories.length,
                itemBuilder: (context, index) {
                  final category = quizCategories[index];
                  return Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        category['title'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to start quiz',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              categoryName: category['title'],
                              questions: category['questions'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> questions;

  const QuizPage({
    required this.categoryName,
    required this.questions,
    super.key,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;

  void _checkAnswer(int selectedIndex) {
    final correctIndex = widget.questions[_currentQuestionIndex]['correct'];
    setState(() {
      _isCorrect = selectedIndex == correctIndex;
      if (_isCorrect) {
        _score++;
      }
      _showFeedback = true;
    });
  }

  void _nextQuestionOrFinish() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
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
            questions: widget.questions,
            categoryName: widget.categoryName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentQuestionIndex];
    final totalQuestions = widget.questions.length;
    final questionNumber = _currentQuestionIndex + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: const Color(0xFFF5E9D4),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display question progress
            Text(
              'Question $questionNumber/$totalQuestions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              question['question'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B0000),
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < question['options'].length; i++)
              ElevatedButton(
                onPressed: _showFeedback
                    ? null
                    : () => _checkAnswer(i),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                ),
                child: Text(question['options'][i]),
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
                    _currentQuestionIndex < widget.questions.length - 1
                        ? 'Next'
                        : 'Finish',
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
  final String categoryName;

  const QuizResultPage({
    required this.score,
    required this.questions,
    required this.categoryName,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.white,
                elevation: 5,
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
                        'Category: $categoryName',
                        style: const TextStyle(
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
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      child: ListTile(
                        title: Text('${index + 1}. ${question['question']}'),
                        subtitle: Text(
                          'Correct Answer: ${question['options'][question['correct']]}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizPage(
                        categoryName: categoryName,
                        questions: questions,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Restart Quiz'),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SafetyQuizPage(),
    ));