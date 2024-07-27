// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorieoperations/calorie.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/widgets/resertpasswordprofile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  File? _image;
  String? _profilePictureUrl;
  String? _username;
  String? _email;
  DateTime? _registrationDate;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _selectedIndex = 2;

  // Navigasyon elemanları

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Sayfa yönlendirmelerini düzeltme
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainMenu()));
        break;
      case 1:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Calendar(),
            ));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const Calorie();
          },
        ));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()));
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    User? user = auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();
      setState(() {
        _profilePictureUrl = userDoc['profilePicture'];
        _username = userDoc['username'];
        _email = userDoc['email'];
        _registrationDate = (userDoc['signupDate'] as Timestamp).toDate();
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadProfilePicture();
    }
  }

  Future<void> _uploadProfilePicture() async {
    User? user = auth.currentUser;
    if (user != null && _image != null) {
      try {
        Reference ref = storage.ref().child('profilePictures/${user.uid}');
        await ref.putFile(_image!);
        String imageUrl = await ref.getDownloadURL();

        await firestore.collection('users').doc(user.uid).update({
          'profilePicture': imageUrl,
        });

        setState(() {
          _profilePictureUrl = imageUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.fromARGB(255, 18, 216, 200),
                    Color.fromARGB(255, 237, 228, 227),
                    Color.fromARGB(255, 255, 128, 0),
                  ],
                ),
              ),
              child: Image(
                image: AssetImage('lib/assets/logo2.png'),
              ),
            ),
            ListTile(
              leading: Image.asset('lib/assets/user.png'),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ));
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/calendar.png'),
              title: const Text(
                'Calendar',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Calendar(),
                    ));
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/settings.png'),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Do something here
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/logout.png'),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                await auth.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const HomePage();
                  },
                ));
              },
            ),
          ],
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Image.asset('lib/assets/menu-bar.png'),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            )
          ],
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
            child: Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 66,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_profilePictureUrl != null
                              ? NetworkImage(_profilePictureUrl!)
                              : const AssetImage('lib/assets/profilll.png'))
                          as ImageProvider,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Card(
        elevation: 50,
        margin: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    _username != null ? 'Welcome, $_username!' : 'no username',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    _registrationDate != null
                        ? 'Registration Date : ${DateFormat('dd MMM yyyy').format(_registrationDate!)}'
                        : 'no registration date',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                    child: Text(
                  _email != null ? 'Email : $_email' : 'no email',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.normal),
                )),
                const SizedBox(height: 40),
                GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      onPressed: () {
                        showEmailDialogInProfile(context);
                      },
                      child: const Text('RESET PASSWORD'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety_outlined),
            label: 'Calorie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
