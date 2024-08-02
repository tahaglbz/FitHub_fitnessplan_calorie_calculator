import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorieoperations/nutrititionix.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:my_app/widgets/appbar.dart';
import 'package:my_app/widgets/side_menu.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../widgets/bottom_nav.dart';

class Calorie extends StatefulWidget {
  const Calorie({super.key});

  @override
  State<Calorie> createState() => _CalorieState();
}

class _CalorieState extends State<Calorie> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 2;
  List<TextEditingController> _foodControllers = [];
  List<TextEditingController> _weightControllers = [];
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
      _foodControllers =
          List.generate(count, (index) => TextEditingController());
      _weightControllers =
          List.generate(count, (index) => TextEditingController());
      _individualCalories = List.generate(count, (index) => '');
    });
  }

  Future<void> _fetchCalories() async {
    double totalCalories = 0.0; // Change to double
    for (int i = 0; i < _foodControllers.length; i++) {
      final foodItem = _foodControllers[i].text;
      final weightText = _weightControllers[i].text;
      if (foodItem.isNotEmpty && weightText.isNotEmpty) {
        final double weight =
            double.tryParse(weightText) ?? 0.0; // Change to double
        if (weight > 0) {
          final caloriesMap =
              await _nutritionixService.getCaloriesAndServingSize(foodItem);
          if (caloriesMap != null) {
            final caloriePerGram =
                _nutritionixService.calculateGramtoCalorie(caloriesMap);
            final calorieValue =
                caloriePerGram != null ? caloriePerGram * weight : 0.0;
            _individualCalories[i] = calorieValue.toStringAsFixed(2);
            totalCalories += calorieValue; // Use double for addition
          } else {
            _individualCalories[i] = '0';
          }
        } else {
          _individualCalories[i] = '0';
        }
      } else {
        _individualCalories[i] = '0';
      }
    }
    setState(() {
      _calories = totalCalories.toStringAsFixed(2);
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
      appBar: CustomAppBar(
        title: 'FitHub',
        autoback: false,
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomSideMenu(auth: _auth),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Card(
            shadowColor: Colors.blueAccent,
            elevation: 9,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
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
                      _foodControllers.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _foodControllers[index],
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    borderSide:
                                        BorderSide(color: Colors.orange),
                                  ),
                                  labelText: 'Enter Meal',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _weightControllers[index],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                    borderSide:
                                        BorderSide(color: Colors.orange),
                                  ),
                                  labelText: 'Enter Weight (grams)',
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
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
                        style: const TextStyle(
                            fontSize: 20, color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
