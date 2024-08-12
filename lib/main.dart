import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'login_screen.dart';
import 'email_generate.dart';

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
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    if (!kIsWeb) {
      _appLinks.uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          print("URI Received: $uri");
          print("Host: ${uri.host}");
          print("Path: ${uri.path}");
          print("Query Parameters: ${uri.queryParameters}");

          if (uri.host == 'duckduckgo.com' && uri.path == '/email/login') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showMessage('You are trying to access DuckDuckGo with OTP: ${uri.queryParameters['otp']}');
            });
          }
        }
      });
    }
    super.initState();
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
          final originalMail = prefs?.getString("originalMail");
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
            home: (username != null && username.isNotEmpty && token != null && token.isNotEmpty && originalMail != null && originalMail.isNotEmpty)
                ? EmailProtectionScreen(
              username: username,
              tokenMail: token,
              originalMail: originalMail,
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
