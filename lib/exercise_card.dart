import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 16,
          bottom: 250,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                "Physical Therapy Program",
                style: TextStyle(fontSize: 19, color: Colors.black),
              ),
            ),
            Icon(
              Icons.edit,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
