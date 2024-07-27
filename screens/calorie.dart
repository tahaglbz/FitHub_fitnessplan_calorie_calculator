// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:http/http.dart' as http;

class Calorie extends StatefulWidget {
  const Calorie({super.key});

  @override
  State<Calorie> createState() => _CalorieState();
}

class _CalorieState extends State<Calorie> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 2;
  final TextEditingController _textController = TextEditingController();
  String _calories = '';

  Future<void> _fetchCalories(String foodItem) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/get_calories'), // Flask API URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'food_item': foodItem}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _calories = data['calories'].toString();
      });
    } else {
      setState(() {
        _calories = 'Error';
      });
    }
  }

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
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const Calendar();
          },
        ));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Calorie()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const ProfileScreen();
          },
        ));
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
                        builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: Image.asset('lib/assets/kcal.png'),
              title: const Text(
                'Calories',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () async {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) {
                    return const Calorie();
                  },
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
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Calendar()));
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Card(
            shadowColor: Colors.blueAccent,
            elevation: 9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Center(
                        child: Text(
                      'Calorie Calculator',
                      style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    )),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                              borderSide: BorderSide(color: Colors.orange)),
                          labelText: 'Enter Meal',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)))),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(200, 50),
                        ),
                        onPressed: () {
                          _fetchCalories(_textController.text);
                        },
                        child: const Text('Get Calories')),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('Calories: ${_calories}'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.black),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.health_and_safety_outlined,
              color: Colors.black,
            ),
            label: 'Calories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
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
