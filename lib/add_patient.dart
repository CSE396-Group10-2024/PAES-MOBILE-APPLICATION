import 'package:flutter/material.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class AddPatientPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AddPatientPage({super.key, required this.user});

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final TextEditingController _patientNumberController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _addPatient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String patientNumber = _patientNumberController.text;

    try {
    var result = await MongoDatabase.addPatient(
      widget.user['_id'].toHexString(),
      patientNumber,
    );

    if (result['success']) {
      Navigator.pop(context, true); // Pass 'true' to indicate success
    } else {
      switch (result['status']) {
        case 1:
          setState(() {
            _errorMessage = 'Patient does not exist.';
          });
          break;
        case 2:
          setState(() {
            _errorMessage = 'Patient already in caregiver\'s list.';
          });
          break;
        case 3:
          setState(() {
            _errorMessage = 'Patient belongs to another caregiver.';
          });
          break;
        default:
          setState(() {
            _errorMessage = 'An unexpected error occurred.';
          });
      }
    }
  } catch (e) {
    print('Error adding patient: $e');
    setState(() {
      _errorMessage = 'Error adding patient: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }


    // Clear the error message after 5 seconds
    if (_errorMessage.isNotEmpty) {
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = '';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _inputField("Patient Number", _patientNumberController),
            const SizedBox(height: 32),
            _isLoading ? CircularProgressIndicator() : _addButton(),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }

  Widget _addButton() {
    return ElevatedButton(
      onPressed: _addPatient,
      child: Text('Add Patient'),
    );
  }
}
