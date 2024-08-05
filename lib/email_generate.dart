import 'dart:convert';  // Importa il pacchetto per lavorare con JSON.
import 'package:duckduckgoemail/api_service.dart';
import 'package:duckduckgoemail/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailProtectionScreen extends StatefulWidget {
  final String username;
  final String tokenMail;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  EmailProtectionScreen({
    required this.username,
    required this.tokenMail,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  _EmailProtectionScreenState createState() => _EmailProtectionScreenState();
}

class _EmailProtectionScreenState extends State<EmailProtectionScreen> {
  final TextEditingController _emailGenController = TextEditingController();
  List<Map<String, String>> _generatedEmails = [];
  var token = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGeneratedEmails();
    _initializeEmailGenerator();
  }

  void _loadGeneratedEmails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('genmail');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      setState(() {
        _generatedEmails = jsonList.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  void _saveGeneratedEmails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(_generatedEmails);
    prefs.setString('genmail', jsonString);
  }

  void _generateCall() {
    generate(widget.username, token).then((onValue) {
      final String generatedTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      setState(() {
        _emailGenController.text = onValue;
        _generatedEmails.add({'email': onValue, 'time': generatedTime});
        _saveGeneratedEmails();
      });
    });
  }

  void _initializeEmailGenerator() {
    getDashboardTotp(widget.tokenMail).then((success) {
      if (success != "null") {
        token = success;
        _generateCall();
      } else {
        _showErrorDialog();
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      _showErrorDialog();
    });
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Errore!'),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Protection'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _selectedIndex == 0 ? _buildGenerateScreen() : _buildHistoryScreen(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Generate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildGenerateScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/email.png',
            height: 150,
          ),
          const SizedBox(height: 20),
          const Text(
            'Autofill enabled in this browser for',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Private Duck Address Generator',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _emailGenController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _emailGenController.text));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (token == "") {
                _initializeEmailGenerator();
              }
              _generateCall();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Generate Private Duck Address'),
          ),
          const SizedBox(height: 20),
          const Text(
            "For sites you don't trust, private Duck Addresses keep your email identity hidden and can be easily deactivated.",
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('username');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    toggleTheme: widget.toggleTheme,
                    themeMode: widget.themeMode,
                  ),
                ),
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return ListView.builder(
      itemCount: _generatedEmails.length,
      itemBuilder: (context, index) {
        final email = _generatedEmails[index]['email'];
        final time = _generatedEmails[index]['time'];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(email!),
            subtitle: Text('Generated at: $time'),
            trailing: IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: email));
              },
            ),
          ),
        );
      },
    );
  }
}
