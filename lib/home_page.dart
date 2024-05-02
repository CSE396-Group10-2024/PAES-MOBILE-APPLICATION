import 'package:flutter/material.dart';
import 'notification_page.dart';
import 'patientProfile_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
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
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  GridItem(title: 'Bed #', destinationPage: PatientProfile()),
                  GridItem(title: 'Bed #', destinationPage: PatientProfile()),
                  GridItem(title: 'Bed #', destinationPage: PatientProfile()),
                  GridItem(title: 'Bed #', destinationPage: PatientProfile()),
                  GridItem(title: 'Profile', destinationPage: PatientProfile()),
                  GridItem(title: 'Profile', destinationPage: PatientProfile()),
                ],
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
            children: List.generate(15, (index) {
              return ListTile(
                title: Text('ROOM # Notification Description'),
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
