import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'package:cengproject/dbhelper/mongodb.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _icon(),
              const SizedBox(height: 20),
              _title(),
              const SizedBox(height: 30),
              _inputField("Username", usernameController),
              const SizedBox(height: 20),
              _inputField("Password", passwordController, isPassword: true),
              const SizedBox(height: 30),
              if (_isLoading) const CircularProgressIndicator(),
              _loginBtn(),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 30),
              _extraText(),
              const SizedBox(height: 10),
              _signupBtn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    final mq = MediaQuery.of(context).size;
    return Image.asset(
      'images/PAES.png',
      width: mq.width * 0.7,
      height: mq.height * 0.3,
    );
  }

  Widget _title() {
    return const Text(
      'PAES',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
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

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 18, 170, 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "LOGIN",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _extraText() {
    return const Text(
      "Don't have an account? Sign Up",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 16, color: Colors.white),
    );
  }

  Widget _signupBtn() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignUpPage()),
        );
      },
      style: ElevatedButton.styleFrom(
<<<<<<< HEAD
        foregroundColor: Colors.white,
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12),
=======
        foregroundColor: Colors.grey,
        backgroundColor: Colors.white,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(vertical: 16),
>>>>>>> main
      ),
      child: const SizedBox(
        width: 150, // Adjust the width as needed
        child: Text(
          "Sign Up",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _login() async {
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

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _errorMessage = '';
        });
      });

      return;
    }

    int isAuthenticated = await MongoDatabase.authenticateUser(username, password);

    setState(() {
      _isLoading = false;
    });

    if (isAuthenticated == 0) {
      var user = await MongoDatabase.getUser(username);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(user: user),
          ),
        );
      }
    } else if (isAuthenticated == 1) {
      setState(() {
        _errorMessage = 'User is already logged in';
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _errorMessage = '';
        });
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _errorMessage = '';
        });
      });
    }
  }
}
