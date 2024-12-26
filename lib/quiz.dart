import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String? selectedCategory;
  List<Map<String, dynamic>> quizQuestions = [];

  final Map<String, List<Map<String, dynamic>>> categories = {
    'Safety & Security': [
      {
        'question': 'What should you do if you encounter a monkey on campus?',
        'answers': [
          'Feed the monkey to calm it down',
          'Stay calm and avoid sudden movements',
          'Try to scare the monkey away by shouting'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'What is the first thing to do if you encounter a snake on campus?',
        'answers': [
          'Catch it and relocate it',
          'Keep a safe distance and contact campus security',
          'Block its path to prevent escape'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'In the event of a fire emergency, what should you avoid using during evacuation?',
        'answers': ['Elevators', 'Fire extinguishers', 'Fire alarms'],
        'correctAnswer': 0
      },
      {
        'question':
            'If you lose an item on campus, what should be your first action?',
        'answers': [
          'Report it to campus security or the lost-and-found department',
          'Wait for someone to find it',
          'Leave the campus and forget about it'
        ],
        'correctAnswer': 0
      },
      {
        'question':
            'What is the first step if you are involved in a minor accident?',
        'answers': [
          'Leave the scene to avoid trouble',
          'Assess the situation and check for injuries',
          'Ignore the situation'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What should you do if you receive an electric shock?',
        'answers': [
          'Immediately touch the person to check for injury',
          'Remove yourself from the source if safe and call for medical help',
          'Wait for the electric shock to pass on its own'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'In a medical emergency, what is the first step?',
        'answers': [
          'Ignore it and continue with your activities',
          'Call campus security or an ambulance immediately',
          'Give the person food or water'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'If you’re caught in a flood, what is the first action?',
        'answers': [
          'Stay where you are',
          'Move to higher ground immediately',
          'Walk through flooded areas to find safety'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What should you do during an earthquake?',
        'answers': [
          'Stand in the doorway',
          'Drop, take cover under furniture, and hold on',
          'Leave the building immediately'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'What should you do if there is a chemical spill on campus?',
        'answers': [
          'Evacuate the area immediately',
          'Wait for someone to clean it up',
          'Touch the spill to assess the damage'
        ],
        'correctAnswer': 0
      }
    ],
    'Health & First Aid': [
      {
        'question': 'In the event of a heat stroke, what should you do first?',
        'answers': [
          'Move to a cooler place and drink water slowly',
          'Sit in the sun to cool off',
          'Apply ice directly to the skin'
        ],
        'correctAnswer': 0
      },
      {
        'question':
            'If someone is experiencing an electric shock, what should you do?',
        'answers': [
          'Continue CPR until help arrives',
          'Immediately touch the person to check for injuries',
          'Remove them from the source of the electric shock if safe to do so'
        ],
        'correctAnswer': 2
      },
      {
        'question': 'What should you do if you encounter a medical emergency?',
        'answers': [
          'Call campus security or an ambulance right away',
          'Ignore the situation and wait for it to resolve',
          'Tell the person to walk it off'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What is the correct procedure for CPR?',
        'answers': [
          'Perform chest compressions only',
          'Tap the person and shout to check for responsiveness, then start chest compressions',
          'Leave the person until professional help arrives'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What is the first aid step if someone is bleeding?',
        'answers': [
          'Apply pressure with a clean cloth to the wound',
          'Wait for the bleeding to stop on its own',
          'Clean the wound with alcohol immediately'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What should you do if someone has a fracture?',
        'answers': [
          'Try to move the person to safety',
          'Immobilize the injured area and avoid moving it',
          'Let them walk it off'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'If you encounter a choking person, what should you do first?',
        'answers': [
          'Perform abdominal thrusts and back blows',
          'Leave them and call for help',
          'Force them to drink water'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What is the first step in providing first aid treatment?',
        'answers': [
          'Ensure the scene is safe before assisting',
          'Apply first aid without checking the environment',
          'Call for help and wait for professionals'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What should you do if someone experiences burns?',
        'answers': [
          'Apply ice directly to the burn',
          'Cool the burn under running water for at least 10 minutes',
          'Wrap the burn in a blanket'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What should you do if someone is in shock?',
        'answers': [
          'Lay them down and elevate their legs slightly, unless there\'s an injury',
          'Keep them standing to maintain blood flow',
          'Ignore them until they recover'
        ],
        'correctAnswer': 0
      }
    ],
    'Environmental & Natural Disasters': [
      {
        'question': 'What should you do if you experience flooding?',
        'answers': [
          'Wait for the water to recede',
          'Move to higher ground immediately',
          'Continue walking through the flooded area'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What is the first thing to do during an earthquake?',
        'answers': [
          'Stand in an open area',
          'Drop to the ground, take cover, and hold on',
          'Immediately run outside'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'If you are inside during a building collapse, what should you do?',
        'answers': [
          'Leave immediately',
          'Take cover under sturdy furniture and protect yourself from debris',
          'Stay in your seat until the shaking stops'
        ],
        'correctAnswer': 1
      },
      {
        'question':
            'If you encounter a chemical spill, what should you do first?',
        'answers': [
          'Evacuate the area and avoid inhaling fumes',
          'Stay in the area to help clean up',
          'Continue working and ignore the spill'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What should you do during an earthquake if you’re inside?',
        'answers': [
          'Hide under a desk and stay away from windows',
          'Run outside immediately',
          'Stay in bed and wait for the shaking to stop'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'If trapped in a collapsed building, what should you do?',
        'answers': [
          'Keep quiet and wait for rescuers to find you',
          'Make noise to alert rescuers and avoid unnecessary movement',
          'Leave the building as soon as possible'
        ],
        'correctAnswer': 1
      },
      {
        'question': 'What should you do if there is a flood?',
        'answers': [
          'Shut off the power if safe to do so',
          'Swim through the flooded area to reach safety',
          'Stay in the flooded area to observe the situation'
        ],
        'correctAnswer': 0
      },
      {
        'question': 'What should you do after an earthquake?',
        'answers': [
          'Leave the area immediately',
          'Wait for instructions from authorities',
          'Check for injuries and assess the situation'
        ],
        'correctAnswer': 2
      },
      {
        'question':
            'What should you do during a building collapse if you’re inside?',
        'answers': [
          'Find a sturdy place to hide and protect yourself from debris',
          'Attempt to escape the building immediately',
          'Wait for help inside the building without moving'
        ],
        'correctAnswer': 0
      },
      {
        'question':
            'During an earthquake, if you are outdoors, what should you do?',
        'answers': [
          'Stay under a tree or a power line',
          'Drop to the ground and take cover under furniture',
          'Stay away from buildings, trees, and power lines'
        ],
        'correctAnswer': 2
      },
    ],
  };

  void setCategory(String? category) {
    setState(() {
      selectedCategory = category;
      quizQuestions = categories[category] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Safety Quiz',
          style: TextStyle(
            color: Color(0xFF8B0000),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF5E9D4),
      ),
      body: selectedCategory == null
          ? CategorySelectionPage(setCategory: setCategory)
          : QuizQuestionPage(
              questions: quizQuestions,
              category: selectedCategory!,
              onBackPressed: () {
                setCategory(null);
              },
            ),
    );
  }
}

class CategorySelectionPage extends StatelessWidget {
  final Function(String?) setCategory;

  CategorySelectionPage({required this.setCategory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          Text(
            'Select a Topic:',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B0000),
            ),
          ),
          SizedBox(height: 10),
          ...[
            'Safety & Security',
            'Health & First Aid',
            'Environmental & Natural Disasters'
          ]
              .map(
                (category) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: ElevatedButton(
                    onPressed: () => setCategory(category),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 60),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                      textStyle: TextStyle(fontSize: 20),
                      backgroundColor: const Color(0xFFF5E9D4),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      category,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
              .toList(),
          SizedBox(height: 20),
          Text(
            'Choose a category to begin the quiz.',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color:
                  Colors.black54, // Subtle text color for secondary information
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestionPage extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final String category;
  final VoidCallback onBackPressed;

  QuizQuestionPage({
    required this.questions,
    required this.category,
    required this.onBackPressed,
  });

  @override
  _QuizQuestionPageState createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String resultMessage = '';

  void answerQuestion(int selectedAnswer) {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
    });

    bool isCorrect = selectedAnswer ==
        widget.questions[currentQuestionIndex]['correctAnswer'];
    if (isCorrect) {
      score++;
      resultMessage = 'Correct! 🎉';
    } else {
      resultMessage = 'Incorrect! ❌';
    }

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionIndex >= widget.questions.length) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Celebration message
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.amber,
                ),
                SizedBox(height: 20),
                Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'You’ve completed the quiz,\n keep up the good work!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  'Your score: $score/${widget.questions.length}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: score == widget.questions.length
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                SizedBox(height: 20),
                // Fun motivational quote or message
                Text(
                  score == widget.questions.length
                      ? 'Perfect! You nailed it! 💯'
                      : 'Great job! You can always improve! ✨',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                // Stylish button to go back to categories
                ElevatedButton(
                  onPressed: widget.onBackPressed,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 50),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                    backgroundColor: const Color(0xFFF5E9D4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Back to Categories'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Additional decorative elements
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 24),
                    SizedBox(width: 5),
                    Text(
                      'Thank you for participating!',
                      style: TextStyle(fontSize: 16, color: Colors.black45),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.star, color: Colors.yellow, size: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = widget.questions[currentQuestionIndex];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E9D4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: Text(
                'Question ${currentQuestionIndex + 1}: ${question['question']}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ...List.generate(
              question['answers'].length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ElevatedButton(
                  onPressed: () => answerQuestion(index),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                    foregroundColor: Colors.black,
                    backgroundColor: isAnswered
                        ? (index == question['correctAnswer']
                            ? Colors.green
                            : const Color.fromARGB(255, 228, 87, 77))
                        : const Color.fromARGB(255, 149, 183, 241),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(question['answers'][index]),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isAnswered)
              Text(resultMessage,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
