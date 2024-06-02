import 'package:cengproject/addExercise_page.dart';
import 'package:flutter/material.dart';

class ExerciseTracker extends StatelessWidget {
  final Map<String, dynamic> patient;

  const ExerciseTracker({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming exercises are part of the patient data structure
    List<Map<String, dynamic>> exercises = patient['exercises'];

    return Container(
      height: 150, // Same height as the ExerciseCard for consistency
      child: ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          var exercise = exercises[index];
          return ListTile(
            leading: Icon(Icons.fitness_center),
            title: Text(exercise['name']),
            subtitle: Text('Repetitions done: ${exercise['repetitions_done']}'),
          );
        },
      ),
    );
  }
}
