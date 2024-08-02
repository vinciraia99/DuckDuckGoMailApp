import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';
import 'email_protection.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  LoginScreen({
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/duck.png',
              height: 150,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () {
                // Simula il login per scopi dimostrativi
                if (_emailController.text.isNotEmpty) {
                  if (kDebugMode) {
                    print(_emailController.text);
                  }
                  try {
                    loginRequest(_emailController.text).then((success) {
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailInboxScreen(
                              email: _emailController.text,
                              toggleTheme: toggleTheme,
                              themeMode: themeMode,
                            ),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog(
                              content: Text('Email o Password errata'),
                            );
                          },
                        );
                      }
                    }).catchError((error) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text('Si è verificato un errore: $error'),
                          );
                        },
                      );
                    });
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text('Si è verificato un errore: $error'),
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return const AlertDialog(
                        content: Text('Email o Password errata'),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
