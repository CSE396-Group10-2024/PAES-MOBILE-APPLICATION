import 'package:cengproject/VideoStreamPage.dart';
import 'exercise_card.dart';
import 'package:flutter/material.dart';
import 'patient_information.dart';

class PatientProfile extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfile({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Determine the background color based on the gender
    Color backgroundColor = patient['gender'] == 'male' ? const Color(0xFF005092) : const Color(0xFFFFC1E3);

    return Scaffold(
      appBar: appBar(context), // Back button
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor, // Set the background color based on gender
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "${patient['room_number']}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PatientInfo(patient: patient),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 150, // Adjust the height as needed
                    child: Row(
                      children: [
                        Expanded(child: ExerciseCard(patient: patient)), // Stretch the ExerciseCard
                      ],
                    ),
                  ),
                  _callButton(context), // Add call button at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: const Text(
        'Patient Profile',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _callButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoStreamPage(patientNumber: patient['patient_number']),
          ),
        );
      },
      icon: const Icon(
        Icons.phone,
        color: Colors.white,
      ),
      label: const Text(
        "Call This Patient",
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
