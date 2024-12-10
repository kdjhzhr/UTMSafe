import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EarlyMeasurementPage extends StatefulWidget {
  @override
  _EarlyMeasurementPageState createState() => _EarlyMeasurementPageState();
}

class _EarlyMeasurementPageState extends State<EarlyMeasurementPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchQuery = ''; // For filtering tips

  // Example list of safety tips
  final List<Map<String, dynamic>> _safetyTips = [
    {
      'title': 'Check Weather Conditions',
      'steps': [
        'Check the weather forecast before heading outdoors.',
        'Wear suitable clothing based on the weather conditions.',
        'Carry rain gear if rain is expected.',
      ],
      'feedback': null, // To store thumbs up feedback
      'comments': [],
      'thumbsUpCount': 0, // Adding thumbsUpCount
    },
    {
      'title': 'Stay Hydrated',
      'steps': [
        'Carry a water bottle with you.',
        'Drink water regularly, especially in hot weather.',
        'Avoid sugary drinks as they can dehydrate you.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Lost Item',
      'steps': [
        'Retrace your steps to the last place you saw the item.',
        'Report the loss to campus security or the lost-and-found department.',
        'Check with nearby facilities or people who might have found it.',
        'If the item is valuable (e.g., laptop, wallet), file a report.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Lost Item',
      'steps': [
        'Retrace your steps to the last place you saw the item.',
        'Report the loss to campus security or the lost-and-found department.',
        'Check with nearby facilities or people who might have found it.',
        'If the item is valuable (e.g., laptop, wallet), file a report.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Monkey Attack',
      'steps': [
        'Stay calm and avoid sudden movements.',
        'Do not feed or provoke the monkeys.',
        'If attacked, back away slowly while avoiding eye contact.',
        'Report to campus security immediately.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Snake Encounter',
      'steps': [
        'Keep a safe distance and do not attempt to catch the snake.',
        'Avoid blocking the snake’s path to escape.',
        'Contact campus security for assistance.',
        'Stay alert and avoid walking in tall grass areas.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Fire Emergency',
      'steps': [
        'Activate the nearest fire alarm.',
        'Evacuate the building immediately via the nearest exit.',
        'Do not use elevators during evacuation.',
        'Call campus security or fire department.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Minor Accident',
      'steps': [
        'Assess the situation and check for injuries.',
        'Apply basic first aid (e.g., bandage for small cuts).',
        'Seek medical help if needed or call for an ambulance.',
        'Report the accident to campus security or the appropriate authorities.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Electric Shock',
      'steps': [
        'Immediately remove yourself from the source of the electric shock if safe to do so.',
        'Call for medical help immediately.',
        'If the person is unconscious or not breathing, start CPR and continue until help arrives.',
        'Do not touch the person until the power is turned off.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Medical Emergency',
      'steps': [
        'Call campus security or an ambulance right away.',
        'Provide the exact location and nature of the emergency.',
        'If the person is conscious, reassure them and keep them calm.',
        'If the person is unconscious, perform necessary first aid until help arrives.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Flooding',
      'steps': [
        'Move to higher ground immediately.',
        'Avoid walking or driving through flooded areas.',
        'Shut off power if you can do so safely.',
        'Listen to official warnings and evacuate if necessary.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Earthquake',
      'steps': [
        'Drop to the ground, take cover under a sturdy piece of furniture, and hold on.',
        'Stay inside if you’re indoors; move away from windows and tall objects.',
        'Once the shaking stops, check for injuries and assess the situation.',
        'Evacuate only when it is safe to do so.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Building Collapse',
      'steps': [
        'If inside, take cover under sturdy furniture to protect yourself from falling debris.',
        'Once the shaking stops, carefully check for injuries and evacuate if possible.',
        'If trapped, remain calm, make noise to alert rescuers, and avoid unnecessary movement.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Chemical Spill',
      'steps': [
        'Evacuate the area immediately and avoid inhaling fumes.',
        'Alert campus security and follow their instructions.',
        'If you are exposed to chemicals, flush affected areas with water and seek medical attention.',
        'Follow the campus’s hazardous materials safety procedures.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Active Shooter',
      'steps': [
        'If possible, run to a safe location or lock yourself in a room.',
        'If running is not an option, hide behind furniture or in closets.',
        'If you cannot escape or hide, prepare to defend yourself as a last resort.',
        'Call campus security or emergency services as soon as possible.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
    {
      'title': 'Heat Stroke/Exhaustion',
      'steps': [
        'Move to a cooler place immediately and rest.',
        'Drink water slowly to rehydrate.',
        'Loosen tight clothing and apply cool, damp cloths to the skin.',
        'If symptoms persist, seek medical attention immediately.',
      ],
      'feedback': null,
      'comments': [],
      'thumbsUpCount': 0,
    },
  ];

  // Function to update thumbs up feedback in Firestore
  Future<void> _setFeedback(int index, String feedbackType) async {
    try {
      // Get the document reference for the safety tip
      DocumentReference tipDoc =
          _firestore.collection('safety_tips').doc('tip_$index');

      // Update the thumbs up count based on feedback type
      if (feedbackType == 'thumbs_up') {
        // Get the current thumbs up count, increment it and update
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(tipDoc);

          if (snapshot.exists) {
            // Get current thumbsUpCount, if it exists, otherwise set to 0
            int currentThumbsUpCount = snapshot['thumbsUpCount'] ?? 0;

            // Increment the thumbs up count
            transaction.update(tipDoc, {
              'thumbsUpCount': currentThumbsUpCount + 1,
            });
          }
        });
      }

      setState(() {
        // Update local feedback state (for UI changes)
        _safetyTips[index]['feedback'] = feedbackType;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update thumbs up: $e')),
      );
    }
  }

  // Function to get the thumbs up count from Firestore
  Future<int> _getThumbsUpCount(int index) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('safety_tips').doc('tip_$index').get();

      if (snapshot.exists) {
        return snapshot['thumbsUpCount'] ?? 0;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load thumbs up count: $e')),
      );
    }
    return 0;
  }

  // Function to filter safety tips based on the search query
  List<Map<String, dynamic>> _getFilteredTips() {
    if (_searchQuery.isEmpty) {
      return _safetyTips;
    }
    return _safetyTips
        .where((tip) =>
            tip['title'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // Function to add a comment for a specific safety tip
  Future<void> _addComment(int index) async {
    final String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      try {
        // Add comment to Firestore
        DocumentReference tipDoc =
            _firestore.collection('safety_tips').doc('tip_$index');
        await tipDoc.update({
          'comments': FieldValue.arrayUnion([
            {'text': commentText}
          ])
        });

        setState(() {
          _safetyTips[index]['comments'].add({'text': commentText});
        });
        _commentController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  // Function to get comments from Firestore for a specific tip
  Stream<QuerySnapshot> _getComments(int index) {
    return _firestore
        .collection('safety_tips')
        .doc('tip_$index')
        .collection('comments')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTips = _getFilteredTips();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Early Measurement Tips'),
        backgroundColor: const Color(0xFFF5E9D4),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Safety Tips',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTips.length,
              itemBuilder: (context, index) {
                final tip = filteredTips[index];
                final feedback = tip['feedback'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ExpansionTile(
                    title: Text(
                      tip['title'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Was this helpful?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B0000),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: feedback == 'thumbs_up'
                                        ? Color(0xFF8B0000)
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    _setFeedback(index, 'thumbs_up');
                                  },
                                ),
                                FutureBuilder<int>(
                                  future: _getThumbsUpCount(index),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    if (snapshot.hasData) {
                                      return Text(
                                        snapshot.data.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B0000),
                                        ),
                                      );
                                    }

                                    return const Text('0');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 2, color: Color(0xFF8B0000)),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.comment,
                                    color: Color(0xFF8B0000),
                                  ),
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
                                                  'Type your comment here...',
                                            ),
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
                                const SizedBox(width: 8),
                                const Text(
                                  'Comments:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF8B0000),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            StreamBuilder<QuerySnapshot>(
                              stream: _getComments(index),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                final comments = snapshot.data!.docs;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
