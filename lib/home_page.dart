import 'package:cengproject/add_patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'patientProfile_page.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  Future<void> _quitApp() async {
    await MongoDatabase.disconnect();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    String caregiverId = user['_id'].toHexString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _quitApp();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: NotificationCard(caregiverId: caregiverId),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: MongoDatabase.getCarePatientsStream(caregiverId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                          title: 'Add Patient',
                          destinationPage: AddPatientPage(user: user),
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

  NotificationCard({required this.caregiverId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: MongoDatabase.getNotifications(caregiverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No notifications found'));
        } else {
          var notifications = snapshot.data!;
          return Card(
            margin: EdgeInsets.all(20),
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
                    title: Text('${notification['room_number']} ${notification['request']}'),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date, style: TextStyle(fontSize: 10)),
                        Text(time, style: TextStyle(fontSize: 10)),
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

  const GridItem({required this.title, required this.destinationPage});

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
        margin: EdgeInsets.all(8),
        child: Center(
          child: Text(title),
        ),
      ),
    );
  }
}
