import 'package:cengproject/dbhelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db, caregiverCollection, patientCollection;

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

      // Access the caregiver collection
      try {
        caregiverCollection = db!.collection(CAREGIVER_COLLECTION);
        // Fetch and print documents in the caregiver collection
        var caregivers = await caregiverCollection!.find().toList();
        if (caregivers.isEmpty) {
          print('Caregiver collection is empty');
        } else {
          print(caregivers);
        }
      } catch (e) {
        print('An error occurred while accessing caregiver collection: $e');
      }

      // Access the patient collection
      try {
        patientCollection = db!.collection(PATIENT_COLLECTION);
        // Fetch and print documents in the patient collection
        var patients = await patientCollection!.find().toList();
        if (patients.isEmpty) {
          print('Patient collection is empty');
        } else {
          print(patients);
        }
      } catch (e) {
        print('An error occurred while accessing patient collection: $e');
      }
    } catch (e) {
      // Handle any errors that occur during connection or querying
      print('An error occurred: $e');
    }
  }

  static Future<bool> authenticateUser(String username, String password) async {
    //await connect(); // Ensure database connection

    try {
      var user =
          await caregiverCollection!.findOne(where.eq('username', username));
      if (user != null) {
        var storedPassword = user['password'];
        if (storedPassword == password) {
          // Simple password check
          return true;
        }
      }
    } catch (e) {
      print('An error occurred during authentication: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> getUser(String username) async {
    var user = await caregiverCollection?.findOne({
      'username': username,
    });
    return user;
  }

  static Future<List<Map<String, dynamic>>> getCarePatients(
      List<String> patientIds) async {
    var objectIds = patientIds.map((id) => ObjectId.parse(id)).toList();
    var patients = await patientCollection!
        ?.find(where.oneFrom('_id', objectIds))
        .toList();
    return patients ?? [];
  }

  static Future<bool> createUser(String username, String password) async {
    //await connect();

    try {
      var existingUser =
          await caregiverCollection!.findOne(where.eq('username', username));
      if (existingUser != null) {
        return false; // User already exists
      }

      var newUser = {
        'username': username,
        'password': password,
        'care_patients': []
      };

      await caregiverCollection!.insertOne(newUser);
      return true;
    } catch (e) {
      print('An error occurred during user creation: $e');
      return false;
    }
  }

  static Future<void> disconnect() async {
    if (db != null) {
      await db!.close();
      print('Database connection closed.');
    }
  }
}
