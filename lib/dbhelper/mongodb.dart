import 'package:cengproject/dbhelper/constant.dart';
import 'package:cengproject/local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  // ignore: prefer_typing_uninitialized_variables
  static var db;

  static Future<void> connect() async {
    try {
      // Establish the database connection
      db = await Db.create(MONGO_CONN_URL);
      await db!.open();
      if (kDebugMode) {
        print('Database connection opened.');
      }

      // Check the server status to confirm connection
      var status = await db!.serverStatus();
      if (status != null) {
        if (kDebugMode) {
          print('Connected to database');
        }
      } else {
        if (kDebugMode) {
          print('Failed to retrieve server status');
        }
        return;
      }
    } catch (e) {
      // Handle any errors that occur during connection or querying
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }

  static Future<int> authenticateUser(String username, String password) async {
    await checkAndReconnectDb();
    try {
      var collection = db!.collection(CAREGIVER_COLLECTION);
      var user = await collection.findOne(where.eq('username', username));
      if (user != null) {
        if (user['is_online'] == true) {
          return 1; // User is already online
        }
        var storedPassword = user['password'];
        if (storedPassword == password) {
          await collection.update(where.id(user['_id']), modify.set('is_online', true));
          return 0; // Success
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred during authentication: $e');
      }
    }
    return 2; // Non-existent user
  }

   static Future<bool> setUserOffline(String userId) async {
    await checkAndReconnectDb();

    final ObjectId id = ObjectId.fromHexString(userId);
    final collection = db!.collection(CAREGIVER_COLLECTION);
    final result = await collection.updateOne(
      where.id(id),
      modify.set('is_online', false),
    );

    return result.isSuccess;
  }

  static Future<Map<String, dynamic>?> getUser(String username) async {
    await checkAndReconnectDb();
    try {
      var collection = db!.collection(CAREGIVER_COLLECTION);
      var user = await collection.findOne({'username': username});
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while getting user: $e');
      }
      return null;
    }
  }

  static Stream<List<Map<String, dynamic>>> getCarePatientsStream(String caregiverId) async* {
    var objectId = ObjectId.parse(caregiverId);
    await checkAndReconnectDb();
    while (db != null && db!.isConnected) {
      try {
        var caregiver = await db!
            .collection(CAREGIVER_COLLECTION)
            .findOne(where.id(objectId));
        
        if (caregiver == null || !caregiver.containsKey('care_patients')) {
          yield [];
        } else {
          var patientIds = List<String>.from(caregiver['care_patients']);
          var objectIds = patientIds.map((id) => ObjectId.parse(id)).toList();
          var patients = await db!
              .collection(PATIENT_COLLECTION)
              .find(where.oneFrom('_id', objectIds))
              .toList();
          yield patients;
        }
      } catch (e) {
        if (kDebugMode) {
          print('An error occurred while fetching care patients: $e');
        }
        yield [];
      }
<<<<<<< HEAD
      await Future.delayed(const Duration(seconds: 10)); // Refresh every 10 seconds
    }
  }

  static Stream<List<Map<String, dynamic>>> getNotifications(String caregiverId) async* {
    var objectId = ObjectId.parse(caregiverId);
    await checkAndReconnectDb();
    while (db != null && db!.isConnected) {
      try {
        var caregiver = await db!
            .collection(CAREGIVER_COLLECTION)
            .findOne(where.id(objectId));
        
        if (caregiver == null || !caregiver.containsKey('notifications')) {
          yield [];
        } else {
          var notifications = List<Map<String, dynamic>>.from(caregiver['notifications']);
          yield notifications;
        }
      } catch (e) {
        if (kDebugMode) {
          print('An error occurred while fetching notifications: $e');
        }
        yield [];
      }
      await Future.delayed(const Duration(seconds: 7)); // Refresh every 7 seconds
=======
      await Future.delayed(const Duration(seconds: 5)); // Fetch new data every 5 seconds
>>>>>>> main
    }
  }

  static Future<bool> createUser(String username, String password) async {
    await checkAndReconnectDb();
    try {
      var existingUser = await db!
          .collection(CAREGIVER_COLLECTION)
          .findOne(where.eq('username', username));
      if (existingUser != null) {
        return false; // User already exists
      }

      var newUser = {
        'username': username,
        'password': password,
        'care_patients': [],
        'notifications': [],
        'is_online': false,
      };

      await db!.collection(CAREGIVER_COLLECTION).insertOne(newUser);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred during user creation: $e');
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>> addPatient(String caregiverId, String patientNumber) async {
    await checkAndReconnectDb();
    try {
      var caregiverCollection = db!.collection(CAREGIVER_COLLECTION);
      var patientCollection = db!.collection(PATIENT_COLLECTION);

      // Check if the patient exists
      var patient = await patientCollection.findOne({'patient_number': patientNumber});
      if (patient == null) {
        if (kDebugMode) {
          print('Patient does not exist.');
        }
        return {'success': false, 'status': 1}; // Patient does not exist
      }

      var patientId = patient['_id'] as ObjectId;
      // ignore: deprecated_member_use
      String patientIdString = patientId.toHexString();

      // Check if the patient is already in the caregiver's list
      var caregiver = await caregiverCollection.findOne(where.id(ObjectId.fromHexString(caregiverId)));
        if (caregiver != null && caregiver['care_patients'] != null) {
          List<String> carePatients = List<String>.from(caregiver['care_patients']);
          if (carePatients.contains(patientIdString)) {
            if (kDebugMode) {
              print('Patient already in caregiver\'s care_patients list.');
            }
            return {'success': false, 'status': 2}; // Patient already in the list
          }
        }

        // Check if the patient already has a personal caregiver
        if (patient['personal_caregiver'] != null && patient['personal_caregiver'].isNotEmpty) {
          if (kDebugMode) {
            print('Patient belongs to another caregiver.');
          }
          return {'success': false, 'status': 3}; // Patient belongs to another caregiver
        }

        // Update the caregiver's array of care_patients with ObjectId as string
        await caregiverCollection.updateOne(
          where.id(ObjectId.fromHexString(caregiverId)),
          modify.push('care_patients', patientIdString),
        );

        // Update the patient's personal_caregiver field with the caregiver's ID
        await patientCollection.updateOne(
          where.id(patientId),
          modify.set('personal_caregiver', caregiverId),
        );

        if (kDebugMode) {
          print('Patient added to caregiver\'s care_patients list and personal_caregiver updated.');
        }
        return {'success': true, 'status': 0}; // Patient added successfully
      } catch (e) {
        if (kDebugMode) {
          print('Error adding patient: $e');
        }
        return {'success': false, 'status': -1}; // Error occurred
      }
    }

  static Future<Map<String, String>> getConnectionAddress(String patientNumber) async {
    await checkAndReconnectDb();
    try {
      var patientCollection = db!.collection(PATIENT_COLLECTION);
      var patient = await patientCollection.findOne(where.eq('patient_number', patientNumber));
      if (patient != null) {
        var connectionAddress = patient['connection_address'];
        if (connectionAddress != null && connectionAddress.contains(':')) {
          var parts = connectionAddress.split(':');
          return {
            'ip': parts[0],
            'port': parts[1]
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while fetching the connection address: $e');
      }
    }
    return {};
  }

  static Stream<void> checkVideoConnectionRequest(String patientId) async* {
    var objectId = ObjectId.parse(patientId);
    await checkAndReconnectDb();
    while (db != null && db!.isConnected) {
      print(patientId);
      try {
        var patient = await db!
            .collection(PATIENT_COLLECTION)
            .findOne(where.id(objectId));

        if (patient != null && patient['requested_video_connection'] == true) {
          // Update the requested_video_connection field to false
          await db!.collection(PATIENT_COLLECTION).update(
              where.id(objectId),
              modify.set('requested_video_connection', false));

          // Extract and format the requested_connection_time
          String requestedConnectionTime = patient['requested_connection_time'];
          DateTime dateTime = DateTime.parse(requestedConnectionTime);
          String formattedTime = '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

          // Show local notification
          String roomNumber = patient['room_number'];
          String patientNum = patient['patient_number'];
          String payload = 'Room: $roomNumber, Patient: $patientNum, Time: $formattedTime'; // Example payload
          await LocalNotifications.showNotification(
              'Video Connection Request',
              'Room: $roomNumber, Patient: $patientNum, Time: $formattedTime',
              payload);
        }
      } catch (e) {
        if (kDebugMode) {
          print('An error occurred while checking video connection request: $e');
        }
      }
      await Future.delayed(const Duration(seconds: 5)); // Check every 10 seconds
      yield null;
    }
  }

  static Future<Map<String, dynamic>> assignRepsToExercises(String patientId, Map<String, int> exerciseReps) async {
    var objectId = ObjectId.parse(patientId);
    await checkAndReconnectDb();

    try {
      var patientCollection = db!.collection(PATIENT_COLLECTION);
      var patient = await patientCollection.findOne(where.id(objectId));

      if (patient == null) {
        return {'success': false, 'status': 2}; // Patient not found
      }

      var todaysExercises = patient['todays_exercises'] ?? {};

      // Check if all reps are zero
      bool allRepsZero = exerciseReps.values.every((reps) => reps == 0);

      if (allRepsZero) {
        return {'success': false, 'status': 1}; // All reps are zero
      }

      // Assign reps to today's exercises
      exerciseReps.forEach((exerciseName, reps) {
        if (todaysExercises.containsKey(exerciseName)) {
          todaysExercises[exerciseName]['assigned_number'] = reps;
        } else {
          todaysExercises[exerciseName] = {'assigned_number': reps, 'repeated_number': 0};
        }
      });

      await patientCollection.update(
        where.id(objectId),
        modify
          ..set('todays_exercises', todaysExercises)
            ..set('are_exercises_assigned', true));

        return {'success': true, 'status': 0}; // Successfully assigned
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred while assigning reps to exercises: $e');
      }
      return {'success': false, 'status': 2}; // Error occurred
    }
  }

  static Future<Map<String, dynamic>> getPatientById(String patientId) async {
    var objectId = ObjectId.parse(patientId);
    await checkAndReconnectDb();
    var patient = await db!
        .collection(PATIENT_COLLECTION)
        .findOne(where.id(objectId));
    return patient;
  }

  static Stream<Map<String, dynamic>> getPatientByIdStream(String patientId) async* {
    var objectId = ObjectId.parse(patientId);
    await checkAndReconnectDb();

    while (db != null && db!.isConnected) {
      try {
        var patient = await db!
            .collection(PATIENT_COLLECTION)
            .findOne(where.id(objectId));

        if (patient != null) {
          yield patient;
        }
      } catch (e) {
        if (kDebugMode) {
          print('An error occurred while fetching patient data: $e');
        }
      }
      await Future.delayed(const Duration(seconds: 2)); // Check every 2 seconds
    }
  }

static Stream<void> resetExercisesStream(String patientId) async* {
    var objectId = ObjectId.parse(patientId);
    if (kDebugMode) {
      print('Resetting exercises for patient $patientId');
    }
    await checkAndReconnectDb();
    while (db != null && db!.isConnected) {  
      try {
        var patientCollection = db!.collection(PATIENT_COLLECTION);
        var patient = await patientCollection.findOne(where.id(objectId));

        if (patient != null) {
          bool isAssigned = patient['are_exercises_assigned'] ?? false;
          bool isCompleted = patient['are_exercises_completed'] ?? false;

          if (isAssigned && isCompleted) {
            var todaysExercises = patient['todays_exercises'] ?? {};

            // Reset the exercises
            todaysExercises.forEach((key, value) {
              value['assigned_number'] = 0;
              value['repeated_number'] = 0;
              
            });

            await patientCollection.updateOne(
              where.id(objectId),
              modify
                ..set('todays_exercises', todaysExercises)
                ..set('are_exercises_assigned', false)
                ..set('are_exercises_completed', false)
            );

            await LocalNotifications.showNotification(
                'Exercises Reset',
                'Exercises for patient ${patient['patient_number']} have been reset.',
                'patient_reset');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('An error occurred while resetting exercises: $e');
        }
      }
      await Future.delayed(const Duration(seconds: 10)); // Check every 10 seconds
      yield null;
    }
  }

  static Future<void> checkAndReconnectDb() async {
    const int maxRetries = 10;
    const int initialDelayMs = 1000; // 1 second
    int retries = 0;

    while (db == null || !db!.isConnected) {

      try {
        if (kDebugMode) {
          print('Database connection is down, attempting to reconnect...');
        }
        await db?.close();
        await connect();
        if (kDebugMode) {
          print('Database reconnected successfully.');
        }
        break; // Exit the loop if connection is successful
      } catch (e) {
        retries += 1;
        if (retries >= maxRetries) {
          if (kDebugMode) {
            print('Failed to reconnect to the database after $maxRetries attempts: $e');
          }
          return;
        }
        if (kDebugMode) {
          print('Reconnection attempt $retries failed: $e');
        }
        await Future.delayed(Duration(milliseconds: initialDelayMs * retries)); // Exponential backoff
      }
    }
    if (kDebugMode) {
      print('Database connection is active.');
    }
  }

  static Future<void> disconnect() async {
    if (db != null) {
      await db!.close();
      if (kDebugMode) {
        print('Database connection closed.');
      }
    }
  }
}
