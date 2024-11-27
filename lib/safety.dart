import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EarlyMeasurementPage extends StatefulWidget {
  const EarlyMeasurementPage({super.key});

  @override
  _EarlyMeasurementPageState createState() => _EarlyMeasurementPageState();
}

class _EarlyMeasurementPageState extends State<EarlyMeasurementPage> {
  final TextEditingController _commentController = TextEditingController();

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List of safety tips (dummy data for this example)
  final List<Map<String, dynamic>> _safetyTips = [
    {
      'title': 'Monkey Attack',
      'steps': [
        'Stay calm and avoid sudden movements.',
        'Do not feed or provoke the monkeys.',
        'If attacked, back away slowly while avoiding eye contact.',
        'Report to campus security immediately.',
      ],
      'comments': []
    },
    {
      'title': 'Snake Encounter',
      'steps': [
        'Keep a safe distance and do not attempt to catch the snake.',
        'Avoid blocking the snake’s path to escape.',
        'Contact campus security for assistance.',
        'Stay alert and avoid walking in tall grass areas.',
      ],
      'comments': []
    },
    {
      'title': 'Fire Emergency',
      'steps': [
        'Activate the nearest fire alarm.',
        'Evacuate the building immediately via the nearest exit.',
        'Do not use elevators during evacuation.',
        'Call campus security or fire department.',
      ],
      'comments': []
    },
    {
      'title': 'Fire Emergency',
      'steps': [
        'Activate the nearest fire alarm.',
        'Evacuate the building immediately via the nearest exit.',
        'Do not use elevators during evacuation.',
        'Call campus security or fire department.',
      ],
      'comments': []
    },
    {
      'title': 'Lost Item',
      'steps': [
        'Retrace your steps to the last place you saw the item.',
        'Report the loss to campus security or the lost-and-found department.',
        'Check with nearby facilities or people who might have found it.',
        'If the item is valuable (e.g., laptop, wallet), file a report.',
      ],
      'comments': []
    },
    {
      'title': 'Minor Accident',
      'steps': [
        'Assess the situation and check for injuries.',
        'Apply basic first aid (e.g., bandage for small cuts).',
        'Seek medical help if needed or call for an ambulance.',
        'Report the accident to campus security or the appropriate authorities.',
      ],
      'comments': []
    },
    {
      'title': 'Electric Shock',
      'steps': [
        'Immediately remove yourself from the source of the electric shock if safe to do so.',
        'Call for medical help immediately.',
        'If the person is unconscious or not breathing, start CPR and continue until help arrives.',
        'Do not touch the person until the power is turned off.',
      ],
      'comments': []
    },
    {
      'title': 'Medical Emergency',
      'steps': [
        'Call campus security or an ambulance right away.',
        'Provide the exact location and nature of the emergency.',
        'If the person is conscious, reassure them and keep them calm.',
        'If the person is unconscious, perform necessary first aid until help arrives.',
      ],
      'comments': []
    },
    {
      'title': 'Flooding',
      'steps': [
        'Move to higher ground immediately.',
        'Avoid walking or driving through flooded areas.',
        'Shut off power if you can do so safely.',
        'Listen to official warnings and evacuate if necessary.',
      ],
      'comments': []
    },
    {
      'title': 'Earthquake',
      'steps': [
        'Drop to the ground, take cover under a sturdy piece of furniture, and hold on.',
        'Stay inside if you’re indoors; move away from windows and tall objects.',
        'Once the shaking stops, check for injuries and assess the situation.',
        'Evacuate only when it is safe to do so.',
      ],
      'comments': []
    },
    {
      'title': 'Building Collapse',
      'steps': [
        'If inside, take cover under sturdy furniture to protect yourself from falling debris.',
        'Once the shaking stops, carefully check for injuries and evacuate if possible.',
        'If trapped, remain calm, make noise to alert rescuers, and avoid unnecessary movement.',
      ],
      'comments': []
    },
    {
      'title': 'Chemical Spill',
      'steps': [
        'Evacuate the area immediately and avoid inhaling fumes.',
        'Alert campus security and follow their instructions.',
        'If you are exposed to chemicals, flush affected areas with water and seek medical attention.',
        'Follow the campus’s hazardous materials safety procedures.',
      ],
      'comments': []
    },
    {
      'title': 'Active Shooter',
      'steps': [
        'If possible, run to a safe location or lock yourself in a room.',
        'If running is not an option, hide behind furniture or in closets.',
        'If you cannot escape or hide, prepare to defend yourself as a last resort.',
        'Call campus security or emergency services as soon as possible.',
      ],
      'comments': []
    },
    {
      'title': 'Heat Stroke/Exhaustion',
      'steps': [
        'Move to a cooler place immediately and rest.',
        'Drink water slowly to rehydrate.',
        'Loosen tight clothing and apply cool, damp cloths to the skin.',
        'If symptoms persist, seek medical attention immediately.',
      ],
      'comments': []
    },
    // Other safety tips omitted for brevity...
  ];

  // Function to add a comment to Firebase Firestore
  Future<void> _addComment(int index) async {
    if (_commentController.text.isNotEmpty) {
      try {
        await _firestore
            .collection('safety_tips')
            .doc('tip_$index')
            .collection('comments')
            .add({
          'text': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  // Function to get comments from Firestore
  Stream<QuerySnapshot> _getComments(int index) {
    return _firestore
        .collection('safety_tips')
        .doc('tip_$index')
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Early Measurement Tips'),
        backgroundColor: const Color(0xFFF5E9D4),
      ),
      body: ListView.builder(
        itemCount: _safetyTips.length,
        itemBuilder: (context, index) {
          final tip = _safetyTips[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ExpansionTile(
              title: Text(
                tip['title'],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...(tip['steps'] as List<String>)
                        .asMap()
                        .entries
                        .map((entry) {
                      final stepIndex = entry.key + 1;
                      final step = entry.value;
                      return ListTile(
                        leading: Text(
                          '$stepIndex.',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B0000)),
                        ),
                        title: Text(step),
                      );
                    }),
                  ],
                ),
                const Divider(thickness: 2, color: Color(0xFF8B0000)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Comments:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF8B0000)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.comment,
                                color: Color(0xFF8B0000)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Add a Comment'),
                                    content: TextField(
                                      controller: _commentController,
                                      decoration: const InputDecoration(
                                          hintText:
                                              'Type your comment here...'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          _addComment(index);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Add Comment'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _getComments(index),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            final comments = snapshot.data!.docs;
                            return ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, commentIndex) {
                                final comment = comments[commentIndex];
                                return ListTile(
                                  title: Text(comment['text']),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
