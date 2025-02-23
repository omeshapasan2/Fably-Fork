import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  AuthTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: EdgeInsets.only(left: 26), // Add left padding here
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(23), // Set the border radius to 34px
          borderSide: BorderSide(width: 1), // Set the border thickness (thin)
        ),
      ),
    );
  }
}

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AuthButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "jura",
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 4,
        ),
        
        
        
        ),
      
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 34), // Set padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(34), // Set border radius
        ),
        elevation: 5, // Set shadow
      ),
    );
  }
}
