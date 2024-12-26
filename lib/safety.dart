import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EarlyMeasurementPage extends StatefulWidget {
  const EarlyMeasurementPage({super.key});

  @override
  _EarlyMeasurementPageState createState() => _EarlyMeasurementPageState();
}

class _EarlyMeasurementPageState extends State<EarlyMeasurementPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTips = [];
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Environmental & Natural Disasters',
    'Health & First Aid',
    'Safety & Security',
  ];

  final List<Map<String, dynamic>> _safetyTips = [
    {
      'id': 'monkey_attack',
      'title': 'Monkey Attack',
      'steps': [
        'Stay calm and avoid sudden movements.',
        'Do not feed or provoke the monkeys.',
        'If attacked, back away slowly while avoiding eye contact.',
        'Report to campus security immediately.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Safety & Security',
    },
    {
      'id': 'snake_encounter',
      'title': 'Snake Encounter',
      'steps': [
        'Keep a safe distance and do not attempt to catch the snake.',
        'Avoid blocking the snake’s path to escape.',
        'Contact campus security for assistance.',
        'Stay alert and avoid walking in tall grass areas.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Safety & Security'
    },
    {
      'id': 'fire_emergency',
      'title': 'Fire Emergency',
      'steps': [
        'Activate the nearest fire alarm.',
        'Evacuate the building immediately via the nearest exit.',
        'Do not use elevators during evacuation.',
        'Call campus security or fire department.',
      ],
      'comments': [],
      'likes': 0,
    },
    {
      'id': 'lost_item',
      'title': 'Lost Item',
      'steps': [
        'Retrace your steps to the last place you saw the item.',
        'Report the loss to campus security or the lost-and-found department.',
        'Check with nearby facilities or people who might have found it.',
        'If the item is valuable (e.g., laptop, wallet), file a report.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Safety & Security'
    },
    {
      'id': 'minor_accident',
      'title': 'Minor Accident',
      'steps': [
        'Assess the situation and check for injuries.',
        'Apply basic first aid (e.g., bandage for small cuts).',
        'Seek medical help if needed or call for an ambulance.',
        'Report the accident to campus security or the appropriate authorities.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
    {
      'id': 'electric_shock',
      'title': 'Electric Shock',
      'steps': [
        'Immediately remove yourself from the source of the electric shock if safe to do so.',
        'Call for medical help immediately.',
        'If the person is unconscious or not breathing, start CPR and continue until help arrives.',
        'Do not touch the person until the power is turned off.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
    {
      'id': 'medical_emergency',
      'title': 'Medical Emergency',
      'steps': [
        'Call campus security or an ambulance right away.',
        'Provide the exact location and nature of the emergency.',
        'If the person is conscious, reassure them and keep them calm.',
        'If the person is unconscious, perform necessary first aid until help arrives.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
    {
      'id': 'flooding',
      'title': 'Flooding',
      'steps': [
        'Move to higher ground immediately.',
        'Avoid walking or driving through flooded areas.',
        'Shut off power if you can do so safely.',
        'Listen to official warnings and evacuate if necessary.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Environmental & Natural Disasters'
    },
    {
      'id': 'earthquake',
      'title': 'Earthquake',
      'steps': [
        'Drop to the ground, take cover under a sturdy piece of furniture, and hold on.',
        'Stay inside if you’re indoors; move away from windows and tall objects.',
        'Once the shaking stops, check for injuries and assess the situation.',
        'Evacuate only when it is safe to do so.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Environmental & Natural Disasters'
    },
    {
      'id': 'building_collapse',
      'title': 'Building Collapse',
      'steps': [
        'If inside, take cover under sturdy furniture to protect yourself from falling debris.',
        'Once the shaking stops, carefully check for injuries and evacuate if possible.',
        'If trapped, remain calm, make noise to alert rescuers, and avoid unnecessary movement.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Environmental & Natural Disasters'
    },
    {
      'id': 'chemical_spill',
      'title': 'Chemical Spill',
      'steps': [
        'Evacuate the area immediately and avoid inhaling fumes.',
        'Alert campus security and follow their instructions.',
        'If you are exposed to chemicals, flush affected areas with water and seek medical attention.',
        'Follow the campus’s hazardous materials safety procedures.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Environmental & Natural Disasters'
    },
    {
      'id': 'active_shooter',
      'title': 'Active Shooter',
      'steps': [
        'If possible, run to a safe location or lock yourself in a room.',
        'If running is not an option, hide behind furniture or in closets.',
        'If you cannot escape or hide, prepare to defend yourself as a last resort.',
        'Call campus security or emergency services as soon as possible.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Safety & Security'
    },
    {
      'id': 'heat_stroke',
      'title': 'Heat Stroke/Exhaustion',
      'steps': [
        'Move to a cooler place immediately and rest.',
        'Drink water slowly to rehydrate.',
        'Loosen tight clothing and apply cool, damp cloths to the skin.',
        'If symptoms persist, seek medical attention immediately.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
    {
      'id': 'cpr',
      'title': 'CPR (Cardiopulmonary Resuscitation)',
      'steps': [
        'Ensure the scene is safe for you and the injured person.',
        'Check for responsiveness by tapping the person and shouting.',
        'If no response and no breathing, call for emergency help immediately.',
        'Start chest compressions: Place your hands in the center of the chest and push hard and fast (100-120 compressions per minute).',
        'If trained, provide rescue breaths after 30 compressions.',
        'Continue CPR until professional help arrives or the person starts breathing.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
    {
      'id': 'first_aid',
      'title': 'First Aid Treatment',
      'steps': [
        'Ensure the scene is safe before assisting.',
        'For bleeding, apply direct pressure to the wound using a clean cloth.',
        'If the person is in shock, lay them down and elevate their legs slightly unless there’s an injury that prevents it.',
        'For burns, cool the burn under running water for at least 10 minutes and cover with a clean, non-fluffy dressing.',
        'For fractures, immobilize the injured area and avoid moving it.',
        'For choking, perform back blows and abdominal thrusts if the person is conscious, or begin CPR if they lose consciousness.',
        'Stay calm and reassure the person until professional help arrives.',
      ],
      'comments': [],
      'likes': 0,
      'category': 'Health & First Aid'
    },
  ];

  void _searchTips() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTips = _safetyTips
          .where((tip) => tip['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _addComment(String tipId) async {
    if (_commentController.text.isNotEmpty) {
      try {
        await _firestore
            .collection('safety_tips')
            .doc(tipId)
            .collection('comments')
            .add({
          'text': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty.')),
      );
    }
  }

  Future<void> _incrementLikes(String id) async {
    try {
      final tipRef = _firestore.collection('safety_tips').doc(id);
      final docSnapshot = await tipRef.get();
      if (docSnapshot.exists) {
        await tipRef.update({
          'likes': FieldValue.increment(1),
        });
      } else {
        await tipRef.set({
          'likes': 1,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add like: $e')),
      );
    }
  }

  Stream<QuerySnapshot> _getComments(String tipId) {
    return _firestore
        .collection('safety_tips')
        .doc(tipId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _filteredTips = _safetyTips; // Initially display all tips
    _searchController.addListener(_searchTips); // Set up search listener
  }

  void _filterTips() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTips = _safetyTips.where((tip) {
        // Check if the tip title contains the search query
        bool matchesSearch = tip['title'].toLowerCase().contains(query);

        // Check if the tip category matches the selected category
        bool matchesCategory =
            _selectedCategory == 'All' || tip['category'] == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                hintText: 'Search for safety tips...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Text('Select Category'),
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                  // Filter tips based on the selected category
                  _filterTips();
                });
              },
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTips.length, // Use filtered list here
              itemBuilder: (context, index) {
                final tip = _filteredTips[index]; // Use filtered list
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
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              title:
                                                  const Text('Add a Comment'),
                                              content: TextField(
                                                controller: _commentController,
                                                decoration: const InputDecoration(
                                                    hintText:
                                                        'Type your comment here...'),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    _addComment(tip['id']);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child:
                                                      const Text('Add Comment'),
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
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up,
                                          color: Color(0xFF8B0000)),
                                      onPressed: () {
                                        _incrementLikes(tip[
                                            'id']); // Call the function to update likes in Firestore
                                        setState(() {
                                          tip['likes'] = (tip['likes'] ?? 0) +
                                              1; // Update the local like count
                                        });
                                      },
                                    ),
                                    Text(
                                      '${tip['likes'] ?? 0}',
                                      style: const TextStyle(
                                          color: Color(0xFF8B0000),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 100,
                              child: StreamBuilder<QuerySnapshot>(
                                stream: _getComments(tip['id']),
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
          ),
        ],
      ),
    );
  }
}
