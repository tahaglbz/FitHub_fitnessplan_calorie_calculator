// ignore_for_file: use_build_context_synchronously, avoid_print

//import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void showEmailDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Center(child: Text('Reset Password')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Please enter email'),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  hintText: 'E-mail',
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 158, 31)))),
              cursorColor: Colors.orange,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'İptal',
              style: TextStyle(color: Color.fromARGB(255, 255, 158, 31)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final String email = emailController.text.trim();
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent.'),
                  ),
                );
                Navigator.of(context).pop();
              } on FirebaseAuthException catch (e) {
                if (e.code == 'invalid-email' ||
                    e.email == null ||
                    e.email == "") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please enter valid email"),
                    duration: Duration(seconds: 3),
                  ));
                }
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(e.message!),
                //   ),
                // );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 158, 31),
                foregroundColor: Colors.white),
            child: const Text('Şifreyi Sıfırla'),
          ),
        ],
      );
    },
  );
}
