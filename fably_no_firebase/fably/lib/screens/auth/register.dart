import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding, if needed
import 'dart:async';
import '../home/home.dart';
import 'login.dart';
import 'auth_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _message = '';
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> registerCustomer(String email, String password) async {
  // Step 1: Retrieve the CSRF token
  final csrfUrl = Uri.parse('http://127.0.0.1:5000/get-csrf-token');
  final csrfResponse = await http.get(csrfUrl);
  
  if (csrfResponse.statusCode != 200) {
    throw Exception("Failed to fetch CSRF token: ${csrfResponse.statusCode}");
  }
  
  // Assume the CSRF token is returned as plain text
  final csrfToken = csrfResponse.body.trim();
  print("CSRF Token: $csrfToken");

  // Step 2: Prepare the login data as JSON
  final loginPayload = jsonEncode({
    'email': email,
    'password': password,
  });

  // Step 3: Send a POST request to the login endpoint with the CSRF token in headers
  final loginUrl = Uri.parse('http://127.0.0.1:5000/register_customer');
  final registerResponse = await http.post(
    loginUrl,
    headers: {
      "Content-Type": "application/json",
      "X-CSRFToken": csrfToken, // Adjust header name if needed
    },
    body: loginPayload,
  );

  // Step 4: Handle the login response
  if (registerResponse.statusCode == 200) {
    // Parse the returned user info

    // Extract cookies from the response headers
    // Note: The cookie string might include additional attributes
    final String? cookies = registerResponse.headers['set-cookie'];
    print("Cookies: $cookies");

    print("Login successful. User info and cookies saved.");
  } else {
    print("Login failed with status code: ${registerResponse.statusCode}");
    print("Response: ${registerResponse.body}");
  }
}

  // Register method
  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      registerCustomer(_emailController.text, _passwordController.text);

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      setState(() {
        _message = 'Account created! Check your email for verification.';
        _isLoading = false;
      });

      // Optionally, navigate to another screen or login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = 'Registration Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  // Google sign-up method
  Future<void> _googleSignUpMethod() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign out from any existing session
      await _googleSignIn.signOut();

      // Now, trigger the Google Sign-In process
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _message = 'Google Sign-In was canceled.';
          _isLoading = false;
        });
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign up to Firebase with the obtained credentials
      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _message = 'Google Sign-In Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Italiana',
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AuthTextField(
                          controller: _emailController, labelText: 'Email'),
                      AuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        obscureText: true,
                      ),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      AuthButton(text: 'Register', onPressed: _register),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Already have an account? Login',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _message,
                        style: TextStyle(
                          fontFamily: 'Jura',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/google_logo.png',
                                height: 40, width: 40),
                            onPressed: _googleSignUpMethod,
                          ),
                          Text(
                            'Sign up via Google',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
