// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorie.dart';
import 'package:my_app/screens/profilescreen.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

  // Navigasyon elemanları

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
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
        ;
    }
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
                    Color.fromARGB(255, 18, 216, 200), // Tam siyah
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
                await _auth.signOut();
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
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          actions: [
            IconButton(
              icon: Image.asset('lib/assets/menu-bar.png'),
              onPressed: () {
                scaffoldKey.currentState?.openEndDrawer();
              },
            )
          ],
          automaticallyImplyLeading: false,
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
