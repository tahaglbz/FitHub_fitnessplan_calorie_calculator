// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorieoperations/nutrititionix.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:numberpicker/numberpicker.dart';

class Calorie extends StatefulWidget {
  const Calorie({super.key});

  @override
  State<Calorie> createState() => _CalorieState();
}

class _CalorieState extends State<Calorie> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 2;
  List<TextEditingController> _controllers = [];
  List<String> _individualCalories = [];
  String _calories = '';
  final NutritionixService _nutritionixService = NutritionixService();
  int _currentValue = 1;

  @override
  void initState() {
    super.initState();
    generateTxtFlds(_currentValue); // Initialize with default value
  }

  void generateTxtFlds(int count) {
    setState(() {
      _controllers = List.generate(count, (index) => TextEditingController());
      _individualCalories = List.generate(count, (index) => '');
      if (_controllers.isNotEmpty) {
        _controllers[0].text = 'example food';
      }
    });
  }

  Future<void> _fetchCalories() async {
    int totalCalories = 0;
    for (int i = 0; i < _controllers.length; i++) {
      final foodItem = _controllers[i].text;
      if (foodItem.isNotEmpty) {
        final calories = await _nutritionixService.getCalories(foodItem);
        final calorieValue = calories != null ? calories : 0;
        _individualCalories[i] = calorieValue.toString();
        totalCalories += calorieValue.toInt(); // Cast to int
      } else {
        _individualCalories[i] = '0';
      }
    }
    setState(() {
      _calories = totalCalories.toString();
    });
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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Calendar()));
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
                            fontSize: 40,
                            fontWeight: FontWeight.w800),
                      )),
                      const SizedBox(height: 10),
                      const Text(
                          'How many pieces of food you consumed in your meal?',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 20),
                      NumberPicker(
                        minValue: 1,
                        maxValue: 9,
                        axis: Axis.horizontal,
                        value: _currentValue,
                        onChanged: (value) {
                          setState(() {
                            _currentValue = value;
                            generateTxtFlds(value);
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ...List.generate(
                        _controllers.length,
                        (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _controllers[index],
                                  decoration: const InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                      borderSide:
                                          BorderSide(color: Colors.orange),
                                    ),
                                    labelText: 'Enter Meal',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text('Calories: ${_individualCalories[index]}'),
                              ],
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            minimumSize: const Size(200, 50),
                          ),
                          onPressed: () {
                            _fetchCalories();
                          },
                          child: const Text('Get Calories')),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total Calories: $_calories',
                          style:
                              TextStyle(fontSize: 20, color: Colors.blueAccent),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: Colors.amber[800], // Seçili öğenin rengi
              unselectedItemColor:
                  Colors.black, // Seçili olmayan öğelerin rengi
              backgroundColor: Colors.white, // Arka plan rengi (isteğe bağlı)
            ),
          ),
          child: BottomNavigationBar(
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
                label: 'Calories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ));
  }
}
