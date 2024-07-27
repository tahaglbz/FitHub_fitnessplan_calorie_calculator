// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/screens/completeprofile.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (formKey.currentState!.validate()) {
      if (passwordController.text == passwordConfirmController.text) {
        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text);
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Signing...')));
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return const CompleteProfile();
            },
          ));
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error : ${e.message}')));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password does not match')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // AppBar yüksekliğini ayarlayın
        child: AppBar(
          title: Text(
            'FitHub',
            style: GoogleFonts.agbalumo(
              textStyle: const TextStyle(color: Colors.white, fontSize: 50),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 73, 144, 201),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                  Color.fromARGB(31, 1, 106, 242),
                  Color.fromARGB(255, 17, 157, 22),
                  Color.fromARGB(255, 255, 158, 31)
                ])),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'lib/assets/logo2.png',
                      height: 200,
                      width: 220,
                    ),
                    TextFormField(
                      controller: emailController,
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
                                  width: 2)),
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Invalid email adress';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 224, 104, 6),
                                  width: 1)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(243, 233, 12, 12),
                                  width: 2)),
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: passwordConfirmController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 224, 104, 6),
                                  width: 1)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(243, 233, 12, 12),
                                  width: 2)),
                          labelStyle: TextStyle(color: Colors.blueAccent)),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 73, 144, 201),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 50)),
                        onPressed: _signUp,
                        child: const Text('Sign Up'))
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
