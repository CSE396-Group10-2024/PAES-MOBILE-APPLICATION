import 'package:cengproject/add_patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'notification_page.dart';
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
            child: NotificationCard(),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationPage()),
        );
      },
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(2, (index) {
              return ListTile(
                title: Text('BED # Notification Description'),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('03-05-2024', style: TextStyle(fontSize: 10)),
                    Text('13:30', style: TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
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
