import 'package:flutter/material.dart';

class AddExercisesPage extends StatefulWidget {
  @override
  _AddExercisesPageState createState() => _AddExercisesPageState();
}

class _AddExercisesPageState extends State<AddExercisesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Exercises'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _exerciseCard('Arm Raises (Left)'),
          _exerciseCard('Arm Raises (Right)'),

          _exerciseCard('Wrist Rotation (Left)'),
          _exerciseCard('Wrist Rotation (Right)'),

          _exerciseCard('Leg Raises (Left)'),
          _exerciseCard('Leg Raises (Right)'),
          _exerciseCard('Neck Rotation'),
        ],
      ),
    );
  }

  Widget _exerciseCard(String exerciseName) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            exerciseName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showRepsDialog(context, exerciseName);
            },
            iconSize: 40,
          ),
        ],
      ),
    );
  }

  Future<void> _showRepsDialog(BuildContext context, String exerciseName) async {
    int reps = 0;

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
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    reps = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    labelText: 'Reps',
                    hintText: 'Enter the number of reps',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Here you can use the value of reps
                print('Reps for $exerciseName: $reps');
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
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
