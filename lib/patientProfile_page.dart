import 'package:cengproject/VideoStreamPage.dart';
import 'package:cengproject/dbhelper/mongodb.dart';
import 'exercise_card.dart';
import 'exercise_info_card.dart'; // Import the ExerciseInfoCard
import 'package:flutter/material.dart';
import 'patient_information.dart';

class PatientProfile extends StatefulWidget {
  final String patientId;

  const PatientProfile({super.key, required this.patientId});

  @override
  _PatientProfileState createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  @override
  void initState() {
    super.initState();
    _startResetExercisesStream();
  }

  void _startResetExercisesStream() {
    MongoDatabase.resetExercisesStream(widget.patientId).listen((_) {
      // Handle any additional logic if needed, for now, it just starts the stream.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context), // Back button
      body: StreamBuilder<Map<String, dynamic>>(
        stream: MongoDatabase.getPatientByIdStream(widget.patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No patient data found'));
          } else {
            var patient = snapshot.data!;
            // Determine the background color based on the gender
            Color backgroundColor = patient['gender'] == 'male' ? const Color(0xFF005092) : const Color(0xFFFFC1E3);

            return Column(
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
                        SizedBox(
                          height: 150, // Adjust the height as needed
                          child: Row(
                            children: [
                              Expanded(child: ExerciseInfoCard(patientId: widget.patientId)), // Stretch the ExerciseInfoCard
                            ],
                          ),
                        ),
                        _callButton(context, patient), // Add call button at the bottom
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
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

  Widget _callButton(BuildContext context, Map<String, dynamic> patient) {
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
