import 'package:flutter/material.dart';
import 'addExercise_page.dart'; // Import the AddExercisesPage

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Physical Therapy Program",
                    style: TextStyle(fontSize: 19, color: Colors.black),
                  ),
                ),
                GestureDetector( // Wrap the Icon with GestureDetector
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddExercisesPage()),
                    );
                  },
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Add some space between text and progress bar
            Text(
              "Today's Progress",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10), // Add some space between text and progress bar
            LinearProgressIndicator(
              value: 0.5, // Set the progress value here (between 0.0 and 1.0)
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}