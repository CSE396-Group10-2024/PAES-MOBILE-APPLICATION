import 'package:flutter/material.dart';

class PatientInfo extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientInfo({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // Extract patient information and convert to uppercase
    String surname = (patient['surname'] ?? 'SURNAME').toUpperCase();
    String firstName = (patient['name'] ?? 'FIRST NAME').toUpperCase();
    String gender = patient['gender'] ?? 'GENDER';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _icon(gender),
        const SizedBox(height: 20),
        Text(
          "$surname, $firstName",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
      ],
=======
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
>>>>>>> main
    );
  }

  Widget _icon(String gender) {
    String assetPath;
    if (gender.toLowerCase() == 'male') {
      assetPath = 'images/male_icon.png';
    } else {
      assetPath = 'images/female_icon.png';
    }
    return Container(
<<<<<<< HEAD
      decoration: BoxDecoration(
=======
      child: const Icon(
        Icons.account_circle,
>>>>>>> main
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        assetPath,
        width: 100,
        height: 100,
      ),
    );
  }
}
