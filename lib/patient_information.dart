import 'package:flutter/material.dart';

class PatientInfo extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientInfo({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _icon(),
          SizedBox(height: 10),
          Row(
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
          SizedBox(height: 10),
          Row(
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
      child: Icon(
        Icons.account_circle,
        color: Colors.white,
        size: 150,
      ),
    );
  }
}
