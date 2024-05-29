import 'package:cengproject/dbhelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddExercisesPage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const AddExercisesPage({super.key, required this.patient});

  @override
  _AddExercisesPageState createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  final Map<String, int> _exerciseReps = {};

  @override
  void initState() {
    super.initState();
    _initializeExerciseReps();
  }

  void _initializeExerciseReps() {
    widget.patient['todays_exercises'].forEach((exerciseName, _) {
      _exerciseReps[exerciseName] = 0;
    });
  }

  Future<void> _assignExercises() async {
    String patientId = widget.patient['_id'].toHexString();
    var result = await MongoDatabase.assignRepsToExercises(patientId, _exerciseReps);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercises assigned successfully.')),
      );
      Navigator.of(context).pop();
    } else {
      String errorMessage;
      switch (result['status']) {
        case 1:
          errorMessage = 'All reps are zero. Please assign at least one rep.';
          break;
        case 2:
          errorMessage = 'Failed to assign exercises. Please try again.';
          break;
        default:
          errorMessage = 'An unknown error occurred. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 43, 170),
        title: const Text('Add Exercises', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              onPressed: _assignExercises,
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
          itemCount: _exerciseReps.length,
          itemBuilder: (context, index) {
            final exerciseName = _exerciseReps.keys.elementAt(index);
            return _exerciseCard(exerciseName);
          },
        ),
      ),
    );
  }

  Widget _exerciseCard(String exerciseName) {
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
              if (_exerciseReps[exerciseName] == 0)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    _showRepsDialog(context, exerciseName);
                  },
                  iconSize: 24,
                )
              else
                Flexible(
                  child: Text(
                    '${_exerciseReps[exerciseName]} reps',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
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
      barrierDismissible: false,
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
