import 'package:flutter/foundation.dart';
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
  Future<void>? _delayedFuture;

  Future<void> _addPatient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String patientNumber = _patientNumberController.text;

    if (patientNumber.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Patient number cannot be empty';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _errorMessage = '';
          });
        }
      });

      return;
    }

    try {
      var result = await MongoDatabase.addPatient(
        widget.user['_id'].toHexString(),
        patientNumber,
      );

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient added successfully')),
          );
          Navigator.pop(context, true); // Pass 'true' to indicate success
        }
      } else {
        setState(() {
          switch (result['status']) {
            case 1:
              _errorMessage = 'Patient does not exist.';
              break;
            case 2:
              _errorMessage = 'Patient already in caregiver\'s list.';
              break;
            case 3:
              _errorMessage = 'Patient belongs to another caregiver.';
              break;
            default:
              _errorMessage = 'An unexpected error occurred.';
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding patient: $e');
      }
      if (mounted) {
        setState(() {
          _errorMessage = 'Error adding patient: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }

    // Clear the error message after 2 seconds
    if (_errorMessage.isNotEmpty) {
<<<<<<< HEAD
      _delayedFuture = Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _errorMessage = '';
          });
        }
=======
      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _errorMessage = '';
        });
>>>>>>> main
      });
    }
  }

  @override
  void dispose() {
    _patientNumberController.dispose();
    // Cancel the delayed future if it's still pending
    _delayedFuture?.then((value) => null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text(
          'Add Patient',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 34, 43, 170),
        iconTheme: const IconThemeData(color: Colors.white),
=======
        title: const Text('Add Patient'),
>>>>>>> main
      ),
      backgroundColor: const Color.fromARGB(255, 34, 43, 170),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _inputField("Patient Number", _patientNumberController),
            const SizedBox(height: 32),
            _isLoading ? const CircularProgressIndicator() : _addButton(),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: Colors.white),
    );

    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        border: border,
        enabledBorder: border,
        focusedBorder: border,
      ),
    );
  }

  Widget _addButton() {
    return ElevatedButton(
      onPressed: _addPatient,
<<<<<<< HEAD
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 18, 170, 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Add Patient",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
=======
      child: const Text('Add Patient'),
>>>>>>> main
    );
  }
}
