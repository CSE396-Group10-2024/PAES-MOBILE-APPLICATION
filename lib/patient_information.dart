import 'package:flutter/material.dart';

class PatientInfo extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientInfo({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _icon(),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "SURNAME, First Name",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "| [GENDER]   |  [BLOOD TYPE] |",
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _icon() {
    return Container(
      child: const Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 150,
      ),
    );
  }
}
