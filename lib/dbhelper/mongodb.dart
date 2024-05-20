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

  static Future<List<Map<String, dynamic>>> getCarePatients(
      List<String> patientIds) async {
    try {
      var objectIds = patientIds.map((id) => ObjectId.parse(id)).toList();
      var patients = await db!
          .collection(PATIENT_COLLECTION)
          .find(where.oneFrom('_id', objectIds))
          .toList();
      return patients;
    } catch (e) {
      print('An error occurred while getting care patients: $e');
      return [];
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
        'care_patients': []
      };

      await db!.collection(CAREGIVER_COLLECTION).insertOne(newUser);
      return true;
    } catch (e) {
      print('An error occurred during user creation: $e');
      return false;
    }
  }

  // this part will be fixed and adjusted so that if patient is not found and stuff aw geez
  static Future<void> addPatient(
      String caregiverId, String patientNumber) async {
    try {
      var caregiverCollection = db!.collection(CAREGIVER_COLLECTION);
      var patientCollection = db!.collection(PATIENT_COLLECTION);

      // Check if the patient exists
      var patient =
          await patientCollection.findOne({'patient_number': patientNumber});
      if (patient == null) {
        print('Patient does not exist.');
        return;
      }

      var patientId = patient['_id'] as ObjectId;

      // Convert ObjectId to string
      // ignore: deprecated_member_use
      String patientIdString = patientId.toHexString();

      // Update the caregiver's array of care_patients with ObjectId as string
      await caregiverCollection.updateOne(
        where.eq('_id', ObjectId.fromHexString(caregiverId)),
        modify.push('care_patients', patientIdString),
      );
      print('Patient added to caregiver\'s care_patients list.');
    } catch (e) {
      print('Error adding patient: $e');
    }
  }

  static Future<void> disconnect() async {
    if (db != null) {
      await db!.close();
      print('Database connection closed.');
    }
  }
}
