import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class ExerciseInfoCard extends StatefulWidget {
  final String patientId;

  const ExerciseInfoCard({super.key, required this.patientId});

  @override
  _ExerciseInfoCardState createState() => _ExerciseInfoCardState();
}

class _ExerciseInfoCardState extends State<ExerciseInfoCard> {
  List<Map<String, dynamic>> _exercises = [];
  int _currentIndex = 0;
  Timer? _timer;
  Timer? _fetchTimer;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
    _startTimers();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fetchTimer?.cancel();
    super.dispose();
  }

  void _fetchExercises() async {
    var patientData = await MongoDatabase.getPatientById(widget.patientId);
    var exercises = patientData['todays_exercises'] ?? {};
    List<Map<String, dynamic>> filteredExercises = [];
    exercises.forEach((name, details) {
      if (details['assigned_number'] > 0) {
        filteredExercises.add({
          'name': name,
          'repeated_number': details['repeated_number'],
          'assigned_number': details['assigned_number'],
        });
      }
    });
    setState(() {
      _exercises = filteredExercises;
    });
  }

  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % (_exercises.isNotEmpty ? _exercises.length : 1);
      });
    });

    _fetchTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      _fetchExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Container(); // Return an empty container if there are no valid exercises
    }

    var currentExercise = _exercises[_currentIndex];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
          children: <Widget>[
            const Text(
              "Assigned Exercises",
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10), // Add some space between text and the next element
            ListTile(
              title: Text(
                currentExercise['name'],
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              trailing: Text(
                "${currentExercise['repeated_number']} / ${currentExercise['assigned_number']}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
