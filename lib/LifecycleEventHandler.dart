import 'package:flutter/widgets.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _disconnectFromDb();
    }
  }

  void _disconnectFromDb() async {
    await MongoDatabase.disconnect();
  }
}
