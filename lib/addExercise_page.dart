import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key});

  @override
  _AddExercisesPageState createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  final Map<String, int> _exerciseReps = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercises'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _exerciseCard('Arm Raise (Left)'),
          _exerciseCard('Arm Raise (Right)'),
          _exerciseCard('Open Arms'),
          _exerciseCard('Squat'),
          _exerciseCard('Leg Raise (Left)'),
          _exerciseCard('Leg Raise (Right)'),
          _exerciseCard('Neck Flexion (Left)'),
          _exerciseCard('Neck Flexion (Right)'),
        ],
      ),
    );
  }

  Widget _exerciseCard(String exerciseName) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          _showRepsDialog(context, exerciseName);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              exerciseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _exerciseReps.containsKey(exerciseName)
                ? Text(
                    '${_exerciseReps[exerciseName]} reps',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showRepsDialog(context, exerciseName);
                    },
                    iconSize: 40,
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRepsDialog(BuildContext context, String exerciseName) async {
    int reps = _exerciseReps[exerciseName] ?? 0;
    final TextEditingController controller = TextEditingController(text: reps.toString());

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Reps for $exerciseName'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    reps = int.tryParse(value) ?? 0;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    hintText: 'Enter the number of reps',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _exerciseReps[exerciseName] = reps;
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
