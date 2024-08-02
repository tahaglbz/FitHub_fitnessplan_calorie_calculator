// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:my_app/widgets/appbar.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final TextEditingController _usernameController = TextEditingController();
  File? _image;
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _completeProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      User? user = auth.currentUser;
      if (user != null) {
        print("User is not null");
        String? imageUrl;
        if (_image != null) {
          final ref =
              storage.ref().child('user_images').child('${user.uid}.jpg');
          try {
            await ref.putFile(_image!);
            imageUrl = await ref.getDownloadURL();
            print("Image uploaded successfully, URL: $imageUrl");
          } catch (error) {
            print("Error uploading image: $error");
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error uploading image: $error')));
            return;
          }
        }

        try {
          await firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'username': _usernameController.text,
            'profilePicture': imageUrl,
            'signupDate': Timestamp.now(),
          });
          print("Profile data added successfully");
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ProfileScreen()));
        } catch (error) {
          print("Error adding profile data: $error");
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding profile data: $error')));
        }
      } else {
        print("User is null");
      }
    } catch (e) {
      print("Caught error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Complete Profile',
        autoback: false,
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
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            controller: _usernameController,
                            decoration:
                                const InputDecoration(labelText: "Username"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  _image != null ? FileImage(_image!) : null,
                              child: _image == null
                                  ? Image.asset('lib/assets/profilll.png')
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: _completeProfile,
                              child: const Text('Complete Profile'))
                        ],
                      ),
                    )),
              ),
            )),
      ),
    );
  }
}
