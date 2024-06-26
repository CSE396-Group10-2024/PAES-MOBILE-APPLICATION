import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cengproject/dbhelper/mongodb.dart';
import 'package:cengproject/add_patient.dart';
import 'package:cengproject/patientProfile_page.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscriptions = [];
    _startCombinedStreams();
  }

  void _startCombinedStreams() {
    for (String patientId in widget.user['care_patients']) {
      var videoConnectionStream = MongoDatabase.checkVideoConnectionRequest(patientId);
      var resetExercisesStream = MongoDatabase.resetExercisesStream(patientId);

      var combinedStream = MergeStream([videoConnectionStream, resetExercisesStream]);

      var subscription = combinedStream.listen((event) {
        // Handle the combined stream events here
        // For example, you might want to trigger some UI updates or other actions
      });

      _subscriptions.add(subscription);
    }
  }

  Future<void> _logout() async {
    // Set the caregiver's online status to false
    await MongoDatabase.setUserOffline(widget.user['_id'].toHexString());
    await MongoDatabase.disconnect();
    SystemNavigator.pop();
  }

  @override
  void dispose() {
    // Ensure any streams or resources are properly closed
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    _logout();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached || state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _setUserOffline();
    }
  }

  Future<void> _setUserOffline() async {
    await MongoDatabase.setUserOffline(widget.user['_id'].toHexString());
  }

  @override
  Widget build(BuildContext context) {
    String caregiverId = widget.user['_id'].toHexString();
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text('Home Page', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 34, 43, 170),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.red,
              ),
              child: const Text('EXIT', style: TextStyle(color: Colors.black)),
            ),
=======
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await _quitApp();
            },
>>>>>>> main
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
                            destinationPage: PatientProfile(patientId: patient['_id'].toHexString()),
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

<<<<<<< HEAD
class NotificationCard extends StatefulWidget {
  final String caregiverId;

  const NotificationCard({super.key, required this.caregiverId});

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: MongoDatabase.getNotifications(widget.caregiverId),
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
=======
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationPage()),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(2, (index) {
              return const ListTile(
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
>>>>>>> main
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
<<<<<<< HEAD
        color: Colors.white.withOpacity(0.3),
=======
>>>>>>> main
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }
}
