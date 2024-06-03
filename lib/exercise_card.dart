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
    double progress = 0.0;

    if (isAssigned && !isCompleted) {
      statusText = "IN PROGRESS...";
      icon = Icons.build;

      num totalAssigned = 0;
      num totalRepeated = 0;
      widget.patient['todays_exercises'].forEach((key, value) {
        totalAssigned += value['assigned_number'];
        totalRepeated += value['repeated_number'] >= value['assigned_number']
            ? value['assigned_number']
            : value['repeated_number'];
      });

      if (totalAssigned > 0) {
        progress = totalRepeated / totalAssigned;
      }
    }

    return GestureDetector(
      onTap: isAssigned && !isCompleted
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddExercisesPage(patient: widget.patient)),
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
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the content vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center the content horizontally
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
              const SizedBox(
                  height:
                      10), // Add some space between text and the next element
              Text(
                statusText,
                textAlign: TextAlign.center, // Center the text
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(
                  height:
                      10), // Add some space between text and progress indicator
              if (isAssigned &&
                  !isCompleted) // Show progress indicator only if exercises are assigned and not completed
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
