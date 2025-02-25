import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../home/home.dart';
import 'register.dart';
import 'auth_widget.dart';
import '../../screens/gender/gender_selection.dart'; // Import for AreYouScreen
import '../../utils/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding, if needed
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();


  Future<String?> getPrefs(String pref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? prefString = prefs.getString(pref);
    
    return prefString;
  }

  Future<void> loginCustomer(String email, String password) async {
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
    final loginUrl = Uri.parse('http://127.0.0.1:5000/login_customer');
    final loginResponse = await http.post(
      loginUrl,
      headers: {
        "Content-Type": "application/json",
        "X-CSRFToken": csrfToken, // Adjust header name if needed
      },
      body: loginPayload,
    );

    // Step 4: Handle the login response
    if (loginResponse.statusCode == 200) {
      // Parse the returned user info
      final Map<String, dynamic> userInfo = jsonDecode(loginResponse.body);
      print("User Info: $userInfo");

      // Extract cookies from the response headers
      // Note: The cookie string might include additional attributes
      final String? cookies = loginResponse.headers['set-cookie'];
      print("Cookies: $cookies");

      // Step 5: Save the user info and cookies using SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInfo', jsonEncode(userInfo));
      if (cookies != null) {
        await prefs.setString('cookies', cookies);
      }

      print("Login successful. User info and cookies saved.");
    } else {
      print("Login failed with status code: ${loginResponse.statusCode}");
      print("Response: ${loginResponse.body}");
    }
  }

  // Login method wrapper to handle void callback
  void _handleLogin() {
    if (!_isLoading) {
      _login();
      loginCustomer(_emailController.text, _passwordController.text);
    }
  }

  // Updated login method
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user?.emailVerified == false) {
        setState(() {
          _message = 'Email not verified. Check your inbox.';
          _isLoading = false;
        });
        return;
      }

      // Check if gender is selected
      bool hasGender = await UserPreferences.hasSelectedGender();
      if (!hasGender) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AreYouScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = 'Login Error: ${e.message}';
        _isLoading = false;
      });
    }
  }

  // Google sign-in method wrapper
  void _handleGoogleSignIn() {
    if (!_isLoading) {
      _googleSignInMethod();
    }
  }

  // Updated Google sign-in method
  Future<void> _googleSignInMethod() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _googleSignIn.signOut();
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

      await _auth.signInWithCredential(credential);

      // Check if gender is selected
      bool hasGender = await UserPreferences.hasSelectedGender();
      if (!hasGender) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AreYouScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _message = 'Google Sign-In Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Forgot password method wrapper
  void _handleForgotPassword() {
    _forgotPassword();
  }

  Future<void> _forgotPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      setState(() {
        _message = 'Password reset email sent.';
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    }
  }

  // Resend verification email method wrapper
  void _handleResendVerification() {
    _resendVerificationEmail();
  }

  Future<void> _resendVerificationEmail() async {
    User? user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      setState(() {
        _message = 'Verification email sent again. Please check your inbox.';
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
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const Text(
                        'Login',
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
                      const SizedBox(height: 20),
                      AuthButton(
                        text: 'Login',
                        onPressed: _isLoading ? () {} : _handleLogin,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: const Text('Forgot Password?',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text("Don't have an account? Register",
                            style: TextStyle(color: Colors.white)),
                      ),
                      if (_message == 'Email not verified. Check your inbox.')
                        ElevatedButton(
                          onPressed: _handleResendVerification,
                          child: const Text('Resend Verification Email'),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        _message,
                        style: const TextStyle(
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
                            onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                          ),
                          const Text(
                            'Login via Google',
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
