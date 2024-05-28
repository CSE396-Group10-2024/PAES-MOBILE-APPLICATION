import 'package:cengproject/add_patient.dart';
import 'package:cengproject/patientProfile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _startVideoConnectionRequestStream();
  }

  void _startVideoConnectionRequestStream() {
    for (String patientId in widget.user['care_patients']) {
      MongoDatabase.checkVideoConnectionRequest(patientId).listen((_) {
        // Stream is managed here, no need to update UI directly
      });
    }
  }

  Future<void> _quitApp() async {
    await MongoDatabase.disconnect();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    String caregiverId = widget.user['_id'].toHexString();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 34, 43, 170),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _quitApp,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
              ),
              child: const Text('EXIT', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 34, 43, 170),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: NotificationCard(caregiverId: caregiverId),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: MongoDatabase.getCarePatientsStream(caregiverId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    var carePatients = snapshot.data!;
                    return GridView.count(
                      crossAxisCount: 2,
                      children: [
                        for (var patient in carePatients)
                          GridItem(
                            title: '${patient['patient_number']}',
                            destinationPage: PatientProfile(patient: patient),
                          ),
                        GridItem(
                          title: 'Add Patient +',
                          destinationPage: AddPatientPage(user: widget.user),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String caregiverId;

  const NotificationCard({super.key, required this.caregiverId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: MongoDatabase.getNotifications(caregiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications found', style: TextStyle(color: Colors.white)));
        } else {
          var notifications = snapshot.data!.reversed.toList(); // Reversing the list to display latest first

          return Card(
            color: Colors.white.withOpacity(0.1),
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: notifications.map((notification) {
                  var requestedAt = notification['requested_at'];
                  DateTime dateTime;

                  // Handle different types of date formats
                  if (requestedAt is Map && requestedAt.containsKey('\$date')) {
                    dateTime = DateTime.parse(requestedAt['\$date']);
                  } else if (requestedAt is String) {
                    dateTime = DateTime.parse(requestedAt);
                  } else {
                    // Fallback in case the date format is unexpected
                    dateTime = DateTime.now();
                  }

                  var date = '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
                  var time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

                  return ListTile(
                    title: Text('${notification['room_number']} ${notification['request']}', style: const TextStyle(color: Colors.white)),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                        Text(time, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final Widget destinationPage;

  const GridItem({super.key, required this.title, required this.destinationPage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationPage),
        );
      },
      child: Card(
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
