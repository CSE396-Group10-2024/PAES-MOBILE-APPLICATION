import 'dart:developer';

import 'package:cengproject/dbhelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static var db, userCollection;

  static connect() async {
    try {
      // Establish the database connection
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      inspect(db);

      // Check the server status to confirm connection
      var status = await db.serverStatus();
      if (status != null) {
        print('Connected to database');
      } else {
        print('Failed to retrieve server status');
        return;
      }

      // Access the user collection
      userCollection = db.collection(USER_COLLECTION);

      // Fetch and print documents in the user collection
      var users = await userCollection.find().toList();
      if (users.isEmpty) {
        print('User collection is empty');
      } else {
        print(users);
      }
    } catch (e) {
      // Handle any errors that occur during connection or querying
      print('An error occurred: $e');
    } finally {
      // Ensure the database connection is closed after operations
      print('Disconnecting from database');
      await db.close();
    }
  }
}
