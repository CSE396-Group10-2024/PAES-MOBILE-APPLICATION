import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExercisesPage extends StatefulWidget {
  const AddExercisesPage({super.key});

  @override
  _AddExercisesPageState createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  final Map<String, int> _exerciseReps = {};
  final List<Map<String, dynamic>> _exercises = [
    {'name': 'Arm Raise (Left)', 'type': 'Arms'},
    {'name': 'Arm Raise (Right)', 'type': 'Arms'},
    {'name': 'Open Arms', 'type': 'Arms'},
    {'name': 'Squat', 'type': 'Legs'},
    {'name': 'Leg Raise (Left)', 'type': 'Legs'},
    {'name': 'Leg Raise (Right)', 'type': 'Legs'},
    {'name': 'Neck Flexion (Left)', 'type': 'Neck'},
    {'name': 'Neck Flexion (Right)', 'type': 'Neck'},
    {'name': 'Default Exercise 1', 'type': 'Default'},
    {'name': 'Default Exercise 2', 'type': 'Default'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 43, 170),
        title: const Text('Add Exercises', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // Add padding to the right
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'ASSIGN',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 34, 43, 170),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3 / 2,
          ),
          itemCount: _exercises.length,
          itemBuilder: (context, index) {
            final exercise = _exercises[index];
            return _exerciseCard(exercise['name'], exercise['type']);
          },
        ),
      ),
    );
  }

  Widget _exerciseCard(String exerciseName, String exerciseType) {
    return Card(
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.all(10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          _showRepsDialog(context, exerciseName);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  exerciseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  exerciseType,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 5),
              if (_exerciseReps.containsKey(exerciseName))
                Flexible(
                  child: Text(
                    '${_exerciseReps[exerciseName]} reps',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _showRepsDialog(context, exerciseName);
                  },
                  iconSize: 24,
                ),
            ],
          ),
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
