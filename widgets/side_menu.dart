// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorieoperations/calorie.dart';
import 'package:my_app/screens/profilescreen.dart';

class CustomSideMenu extends StatelessWidget {
  final FirebaseAuth auth;

  const CustomSideMenu({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset('lib/assets/kcal.png'),
            title: const Text(
              'Calories',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () async {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return const Calorie();
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset('lib/assets/calendar.png'),
            title: const Text(
              'Calendar',
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Calendar(),
                ),
              );
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return const HomePage();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
