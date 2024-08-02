// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:my_app/screens/calorieoperations/calorie.dart';
import 'package:my_app/widgets/appbar.dart';
import 'package:my_app/widgets/side_menu.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/screens/mainscreen.dart';
import 'package:my_app/screens/profilescreen.dart';
import 'package:my_app/screens/calendarscreens/daydetail.dart';

import '../../widgets/bottom_nav.dart';

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
            color: data['isChecked']
                ? Colors.grey
                : priorityColor, // Use color based on isChecked
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
      appBar: CustomAppBar(
        title: 'FitHub',
        autoback: false,
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomSideMenu(auth: _auth),
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
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
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
