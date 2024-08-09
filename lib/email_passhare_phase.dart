import 'package:duckduckgoemail/email_generate.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_screen.dart';

class EmailInboxScreen extends StatefulWidget {
  final String email;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  EmailInboxScreen({
    required this.email,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  _EmailInboxScreenState createState() => _EmailInboxScreenState();
}

class _EmailInboxScreenState extends State<EmailInboxScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/duck.png', // Percorso dell'immagine dell'icona
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text('Account verification'),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: constraints.maxWidth < 600 ? double.infinity : 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/email.png', // Percorso dell'immagine
                        height: 150, // Altezza dell'immagine
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Check your inbox!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Open the link we sent to ${widget.email} in this app or enter the one-time passphrase below.',
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
                      SizedBox(
                        width: double.infinity,
                        height: 50, // Aumenta l'altezza del pulsante di login
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Colore di sfondo
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18, // Aumenta la dimensione del testo
                              color: Colors.white, // Colore del testo
                            ),
                          ),
                          onPressed: () {
                            if (_otpController.text.isNotEmpty) {
                              login(widget.email, _otpController.text).then((success) {
                                if (success.isNotEmpty) {
                                getDashboardTotp(success).then((onValue){
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmailProtectionScreen(
                                        username: widget.email,
                                        tokenMail:  onValue["otp"],
                                        originalMail: onValue["email"],
                                        toggleTheme: widget.toggleTheme,
                                        themeMode: widget.themeMode,
                                      ),
                                    ),
                                  );
                                });
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AlertDialog(
                                        content: Text('Login failed. Please try again.'),
                                      );
                                    },
                                  );
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          // Gestisci l'azione di reinvio
                        },
                        child: const Text(
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
                                toggleTheme: widget.toggleTheme,
                                themeMode: widget.themeMode,
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
            ),
          );
        },
      ),
    );
  }
}
