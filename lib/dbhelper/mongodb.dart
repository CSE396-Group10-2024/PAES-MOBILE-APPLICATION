import 'package:cengproject/dbhelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db;

  static Future<void> connect() async {
    try {
      // Establish the database connection
      db = await Db.create(MONGO_CONN_URL);
      await db!.open();
      print('Database connection opened.');

      // Check the server status to confirm connection
      var status = await db!.serverStatus();
      if (status != null) {
        print('Connected to database');
      } else {
        print('Failed to retrieve server status');
        return;
      }
    } catch (e) {
      // Handle any errors that occur during connection or querying
      print('An error occurred: $e');
    }
  }

  static Future<bool> authenticateUser(String username, String password) async {
    try {
      var collection = db!.collection(CAREGIVER_COLLECTION);
      var user = await collection.findOne(where.eq('username', username));
      if (user != null) {
        var storedPassword = user['password'];
        if (storedPassword == password) {
          return true;
        }
      }
    } catch (e) {
      print('An error occurred during authentication: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      var collection = db!.collection(CAREGIVER_COLLECTION);
      var user = await collection.findOne({'username': username});
      return user;
    } catch (e) {
      print('An error occurred while getting user: $e');
      return null;
    }
  }

  static Stream<List<Map<String, dynamic>>> getCarePatientsStream(String caregiverId) async* {
    var objectId = ObjectId.parse(caregiverId);
    while (await db!.serverStatus() != null) {
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
        print('An error occurred while fetching care patients: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 5)); // Fetch new data every 5 seconds
    }
  }

  static Stream<List<Map<String, dynamic>>> getNotifications(String caregiverId) async* {
  var objectId = ObjectId.parse(caregiverId);
  while (await db!.serverStatus() != null) {
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
      print('An error occurred while fetching notifications: $e');
      yield [];
    }
    await Future.delayed(const Duration(seconds: 5)); // Fetch new data every 5 seconds
  }
}


  static Future<bool> createUser(String username, String password) async {
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
        'notifications': []
      };

      await db!.collection(CAREGIVER_COLLECTION).insertOne(newUser);
      return true;
    } catch (e) {
      print('An error occurred during user creation: $e');
      return false;
    }
  }

  // still wont check the case of if patient is already connected with a caregiver also 
  // needs to set variable from patient to indicate it is connected to a caregiver
  static Future<Map<String, dynamic>> addPatient(String caregiverId, String patientNumber) async {
  try {
    var caregiverCollection = db!.collection(CAREGIVER_COLLECTION);
    var patientCollection = db!.collection(PATIENT_COLLECTION);

    // Check if the patient exists
    var patient = await patientCollection.findOne({'patient_number': patientNumber});
    if (patient == null) {
      print('Patient does not exist.');
      return {'success': false, 'status': 1}; // Patient does not exist
    }

    var patientId = patient['_id'] as ObjectId;
    String patientIdString = patientId.toHexString();

    // Check if the patient is already in the caregiver's list
    var caregiver = await caregiverCollection.findOne(where.id(ObjectId.fromHexString(caregiverId)));
    if (caregiver != null && caregiver['care_patients'] != null) {
      List<String> carePatients = List<String>.from(caregiver['care_patients']);
      if (carePatients.contains(patientIdString)) {
        print('Patient already in caregiver\'s care_patients list.');
        return {'success': false, 'status': 2}; // Patient already in the list
      }
    }

    // Check if the patient already has a personal caregiver
    if (patient['personal_caregiver'] != null && patient['personal_caregiver'].isNotEmpty) {
      print('Patient belongs to another caregiver.');
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

    print('Patient added to caregiver\'s care_patients list and personal_caregiver updated.');
    return {'success': true, 'status': 0}; // Patient added successfully
  } catch (e) {
    print('Error adding patient: $e');
    return {'success': false, 'status': -1}; // Error occurred
  }
}


  static Future<void> disconnect() async {
    if (db != null) {
      await db!.close();
      print('Database connection closed.');
    }
  }
}
