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
  var originaMail = "";
  bool _emailGenerated = false;  // Variabile di stato per tenere traccia se la mail è già stata generata
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
    if (_emailGenerated) return;  // Evita di rigenerare la mail se già generata
    generate(widget.username, token).then((onValue) {
      final String generatedTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      setState(() {
        if(onValue != "null" && !_isDuplicate(onValue)) {
          _emailGenController.text = onValue;
          _generatedEmails.add({'email': onValue, 'time': generatedTime});
          _saveGeneratedEmails();
          _emailGenerated = true;  // Imposta la variabile di stato a true dopo la generazione
        }
      });
    });
  }

  bool _isDuplicate(String email) {
    return _generatedEmails.any((element) => element['email'] == email);
  }

  void _initializeEmailGenerator() {
    getDashboardTotp(widget.tokenMail).then((success) {
      if (success["otp"] != "null") {
        originaMail = success["email"];
        token = success["otp"];
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
        title: Row(
          children: [
            Image.asset(
              'assets/duck.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text('Email Protection'),
          ],
        ),
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
          Text(
            'This is default relay mail for $originaMail:',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${widget.username}@duck.com",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: "${widget.username}@duck.com"));
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Private Duck Address Generator',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final maxWidth = isSmallScreen ? double.infinity : 400.0;

              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Row(
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
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (token == "") {
                _initializeEmailGenerator();
              }
              _emailGenerated = false;
              _generateCall();
              _emailGenerated = true;
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
              await prefs.remove("genmail");
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
