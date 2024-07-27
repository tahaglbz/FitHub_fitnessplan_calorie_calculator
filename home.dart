// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/auth/login.dart';
import 'package:my_app/auth/signup.dart';
import 'package:my_app/screens/completeprofile.dart';
import 'package:my_app/screens/mainscreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Firebase ile giriş yap
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          if (userDoc.exists) {
            var userData = userDoc.data() as Map<String, dynamic>;
            if (userData.containsKey('username') &&
                userData.containsKey('profilePicture')) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainMenu()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CompleteProfile()),
              );
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CompleteProfile()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in failed')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in error: ${error.toString()}')),
      );
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/logo2.png',
              height: 300,
              width: 400,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(270, 50),
                backgroundColor: const Color.fromARGB(255, 73, 144, 201),
              ),
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(270, 50),
                backgroundColor: const Color.fromARGB(255, 73, 144, 201),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                _signInWithGoogle(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(270, 50),
                backgroundColor: Colors.white,
              ),
              icon: Image.asset(
                'lib/assets/google.png',
                height: 24,
                width: 24,
              ),
              label: const Text(
                'Continue with Google',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
