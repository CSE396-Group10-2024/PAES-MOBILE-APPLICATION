import 'exercise_card.dart';
import 'package:flutter/material.dart';
import 'patient_information.dart';

class PatientProfile extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfile({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(), //back button
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.pink[200], // Set the background color to pink
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "${patient['room_number']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 40, color: Colors.white),
                              ),
                            ),
                            PatientInfo(patient: patient),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.white,
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          ExerciseCard(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return AppBar(
      title: const Text('Patient Profile'),
    );
  }
}
