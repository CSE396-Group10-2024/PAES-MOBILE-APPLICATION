import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String username = usernameController.text;
    String password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Username and password cannot be empty';
      });

      Future.delayed(const Duration(seconds: 5), () {
        setState(() {
          _errorMessage = '';
        });
      });

      return;
    }

    bool isCreated = await MongoDatabase.createUser(username, password);

    setState(() {
      _isLoading = false;
    });

    if (isCreated) {
      // Navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      setState(() {
        _errorMessage = 'Username already exists';
      });

      Future.delayed(const Duration(seconds: 5), () {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 34, 43, 170),
      body: _page(),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              _inputField("Username", usernameController),
              const SizedBox(height: 20),
              _inputField("Password", passwordController, isPassword: true),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator(),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              _signupBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    var border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white, width: 2),
    );

    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      obscureText: isPassword,
    );
  }

  Widget _signupBtn() {
    return ElevatedButton(
      onPressed: _signUp,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 18, 170, 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Sign Up",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
