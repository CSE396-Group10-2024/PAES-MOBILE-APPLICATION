import 'package:cengproject/addExercise_page.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ExerciseCard({super.key, required this.patient});

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    bool isAssigned = widget.patient['are_exercises_assigned'] ?? false;
    bool isCompleted = widget.patient['are_exercises_completed'] ?? false;
    String statusText = "UNASSIGNED";
    IconData icon = Icons.edit;

    if (isAssigned && !isCompleted) {
      statusText = "IN PROGRESS...";
      icon = Icons.build;
    }

    return GestureDetector(
      onTap: isAssigned && !isCompleted
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExercisesPage(patient: widget.patient)),
              );
            },
      child: Card(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      "Physical Therapy Program",
                      textAlign: TextAlign.center, // Center the text
                      style: TextStyle(fontSize: 19, color: Colors.black),
                    ),
                  ),
                  Icon(
                    icon,
                    color: Colors.black,
                  ),
                ],
              ),
              const SizedBox(height: 10), // Add some space between text and the next element
              Text(
                statusText,
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
