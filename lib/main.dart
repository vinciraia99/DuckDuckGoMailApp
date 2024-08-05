import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'login_screen.dart';
import 'email_generate.dart'; // Assicurati di avere i percorsi corretti

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final AppLinks _appLinks = AppLinks();

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == 'duckduckgo.com') {
        _showMessage('You are trying to access duckduckgo.com');
      }
    });
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final prefs = snapshot.data;
          final token = prefs?.getString("token");
          final username = prefs?.getString("username");

          return MaterialApp(
            title: 'DuckDuckGo Email Relay',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            themeMode: _themeMode,
            home: (username != null && token != null)
                ? EmailProtectionScreen(
              username: username,
              tokenMail: token,
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
            )
                : LoginScreen(
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
          );
        } else {
          return MaterialApp(
            title: 'DuckDuckGo Email Relay',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            themeMode: _themeMode,
            home: LoginScreen(
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
            ),
          );
        }
      },
    );
  }
}
