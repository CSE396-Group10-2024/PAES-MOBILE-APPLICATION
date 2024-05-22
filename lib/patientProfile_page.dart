import 'package:cengproject/VideoStreamPage.dart';
import 'exercise_card.dart';
import 'package:flutter/material.dart';
import 'patient_information.dart';

class PatientProfile extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfile({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), //back button and camera icon
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

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      title: const Text('Patient Profile'),
      actions: [
        IconButton(
          icon: Icon(Icons.camera_alt_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoStreamPage(),
              ),
            );
          },
        ),
      ],
    );
  }
}
