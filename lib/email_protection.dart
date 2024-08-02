import 'package:duckduckgoemail/email_generate.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';

class EmailInboxScreen extends StatelessWidget {
  final TextEditingController _otpController = TextEditingController();
  final String email;

  EmailInboxScreen({required this.email, required VoidCallback toggleTheme, required ThemeMode themeMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              const Text(
                'Check your inbox!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Open the link we sent to $email in this browser or enter the one-time passphrase below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Enter your one-time passphrase',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_otpController.text.isNotEmpty) {
                    login(email, _otpController.text).then((success) {
                      if (success != "") {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => EmailProtectionScreen(username: email, tokenMail: success, toggleTheme: () {  }, themeMode:  ThemeMode.light,))
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: Text('Login failed. Please try again.'),
                            );
                          },
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Sign In'),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Handle resend action
                },
                child: Text(
                  "Didn't get the email? Resend",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen(toggleTheme: () {  }, themeMode:  ThemeMode.light,)),
                  );
                },
                child: Text(
                  "Mail not correct? Go back",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
