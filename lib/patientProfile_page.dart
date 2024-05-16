import 'exercise_card.dart';
import 'package:flutter/material.dart';
import 'patient_information.dart';

class PatientProfile extends StatelessWidget {

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
                child: Container( // Wrap the Column with Container
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
                                "Bed No.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 40, color: Colors.white),
                              ),
                            ),
                            PatientInfo(),
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
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget appBar(){
    return AppBar(
    );
  }
}
