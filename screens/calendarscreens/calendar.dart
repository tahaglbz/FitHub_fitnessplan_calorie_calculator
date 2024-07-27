import 'package:flutter/material.dart';
import 'package:my_app/screens/calorie.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/home.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:my_app/screens/calendarscreens/daydetail.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 1; // Calendar screen is selected by default
  late CalendarController _calendarController;
  List<Appointment> _appointments = [];

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _calendarController.displayDate = DateTime.now();
    _fetchAppointments();
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

  Future<void> _fetchAppointments() async {
    try {
      CollectionReference remindersCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('reminders');

      QuerySnapshot snapshot = await remindersCollection.get();

      List<Appointment> appointments = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          DateTime date = (data['date'] as Timestamp).toDate();
          Color priorityColor;

          switch (data['priority']) {
            case 1:
              priorityColor = Colors.red;
              break;
            case 2:
              priorityColor = Colors.orange;
              break;
            case 3:
              priorityColor = Colors.green;
              break;
            default:
              priorityColor = Colors.grey;
          }

          appointments.add(Appointment(
            startTime: date,
            endTime: date,
            subject: data['title'] ?? 'No Title',
            color: priorityColor,
            notes: data['description'] ?? 'No Description',
          ));
        }
      }

      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      // Handle the error appropriately
      print('Error fetching appointments: $e');
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
              leading: Image.asset('lib/assets/calendar.png'),
              title: const Text(
                'Calendar',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                // Navigate to Calendar
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(43.0),
            child: SfCalendar(
              controller: _calendarController,
              view: CalendarView.month,
              todayHighlightColor: const Color.fromARGB(255, 255, 158, 31),
              initialDisplayDate: DateTime.now(),
              headerHeight: 0,
              monthViewSettings: const MonthViewSettings(
                showTrailingAndLeadingDates: true,
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                navigationDirection: MonthNavigationDirection.horizontal,
                showAgenda: false,
              ),
              dataSource: MeetingDataSource(_appointments),
              appointmentBuilder: (context, details) {
                final Appointment appointment = details.appointments.first;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        bottom: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: appointment.color,
                          ),
                          width: 8,
                          height: 8,
                        ),
                      ),
                      // Text details for the appointment
                      // Positioned(
                      //   left: 15,
                      //   bottom: 0,
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         appointment.subject,
                      //         style: TextStyle(
                      //             fontSize: 12, fontWeight: FontWeight.bold),
                      //       ),
                      //       Text(
                      //         appointment.notes!,
                      //         style:
                      //             TextStyle(fontSize: 10, color: Colors.grey),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
              onTap: calendarTapped,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        DateTime currentDate = _calendarController.displayDate!;
                        _calendarController.displayDate = DateTime(
                          currentDate.year,
                          currentDate.month - 1,
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_calendarController.displayDate!.month}/${_calendarController.displayDate!.year}',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        DateTime currentDate = _calendarController.displayDate!;
                        _calendarController.displayDate = DateTime(
                          currentDate.year,
                          currentDate.month + 1,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
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

  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return DayDetailsScreen(selectedDate: details.date!);
        },
      ));
    }
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
