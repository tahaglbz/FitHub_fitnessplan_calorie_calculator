import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/calendarscreens/calendar.dart';
import 'package:my_app/screens/calorieoperations/calorie.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:my_app/widgets/appbar.dart';
import 'package:my_app/widgets/bottom_nav.dart';
import 'package:my_app/widgets/side_menu.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;

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
              builder: (context) => const Calendar(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: scaffoldKey,
        title: 'FitHub',
        autoback: false,
      ),
      endDrawer: CustomSideMenu(auth: _auth),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: const Center(
        child:
            Text('Main Menu Content'), // Replace this with your actual content
      ),
    );
  }
}
