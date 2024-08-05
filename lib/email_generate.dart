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
  final List<Map<String, String>> _generatedEmails = [];
  var token = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeEmailGenerator();
  }

  void _generateCall(){
    generate(widget.username, token).then((onValue){
      final String generatedTime = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
      setState(() {
        _emailGenController.text = onValue;
        _generatedEmails.add({'email': onValue, 'time': generatedTime});
      });
    });
  }

  void _initializeEmailGenerator() {
    getDashboardTotp(widget.tokenMail).then((success) {
      if (success != "null") {
        token = success;
        _generateCall();
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Errore!'),
            );
          },
        );
      }
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Errore!'),
          );
        },
      );
    });
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextField(
                    controller: _emailGenController,
                    readOnly: true,
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
            onPressed: (){
              if(token == ""){
                _initializeEmailGenerator();
              }
              _generateCall();
            }, // Genera nuovo indirizzo email
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Background color
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
