import 'package:flutter/material.dart';
import 'package:duckduckgoemail/email_generate.dart'; // Assicurati di avere i percorsi corretti
import 'api_service.dart';
import 'login_screen.dart';

class EmailInboxScreen extends StatelessWidget {
  final TextEditingController _otpController = TextEditingController();
  final String email;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  EmailInboxScreen({
    required this.email,
    required this.toggleTheme,
    required this.themeMode,
  });

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
              const SizedBox(height: 20),
              Text(
                'Open the link we sent to $email in this browser or enter the one-time passphrase below.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_otpController.text.isNotEmpty) {
                    login(email, _otpController.text).then((success) {
                      if (success.isNotEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailProtectionScreen(
                              username: email,
                              tokenMail: success,
                              toggleTheme: toggleTheme,
                              themeMode: themeMode,
                            ),
                          ),
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
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(
                        toggleTheme: toggleTheme,
                        themeMode: themeMode,
                      ),
                    ),
                  );
                },
                child: const Text(
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
