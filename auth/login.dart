// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/widgets/resetpassword.dart';
import 'package:my_app/screens/mainscreen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage;

  Future<void> signInWithEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => MainMenu()));
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          title: Text(
            'FitHub',
            style: GoogleFonts.agbalumo(
              textStyle: const TextStyle(color: Colors.white, fontSize: 50),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 73, 144, 201),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(31, 1, 106, 242),
                  Color.fromARGB(255, 17, 157, 22),
                  Color.fromARGB(255, 255, 158, 31),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Card(
            elevation: 9,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/logo2.png',
                      height: 200,
                      width: 220,
                    ),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 224, 104, 6),
                              width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(243, 233, 12, 12),
                              width: 2),
                        ),
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Invalid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 224, 104, 6),
                              width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(243, 233, 12, 12),
                              width: 2),
                        ),
                        labelStyle: TextStyle(color: Colors.blueAccent),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 73, 144, 201),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 50)),
                        onPressed: signInWithEmail,
                        child: const Text('Login')),
                    TextButton(
                        onPressed: () {
                          showEmailDialog(context);
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                              color: Color.fromARGB(255, 73, 144, 201)),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
