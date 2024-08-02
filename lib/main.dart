import 'package:duckduckgoemail/email_generate.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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
  Widget build(BuildContext context) {
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
      /*home: EmailProtectionScreen(
        username: "test",
        tokenMail: "test",
        toggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),*/
      home: LoginScreen( toggleTheme: _toggleTheme,
        themeMode: _themeMode,),
    );
  }
}
