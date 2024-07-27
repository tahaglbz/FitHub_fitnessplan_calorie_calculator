// day_details_screen.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reminder.dart'; // Add this import

class DayDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;

  DayDetailsScreen({required this.selectedDate});

  @override
  _DayDetailsScreenState createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  Stream<List<Reminder>> fetchReminders(String userId, DateTime selectedDate) {
    CollectionReference reminders = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('reminders');
    return reminders
        .where('date', isEqualTo: Timestamp.fromDate(selectedDate))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reminder.fromFirestore(doc)).toList());
  }

  Future<void> addReminder(
      String title, String description, DateTime date, int priority) async {
    CollectionReference reminders = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders');
    return reminders
        .add({
          'title': title,
          'description': description,
          'date': Timestamp.fromDate(date),
          'priority': priority,
        })
        .then((value) => print("Reminder Added"))
        .catchError((error) => print("Failed to add reminder: $error"));
  }

  Future<void> deleteReminder(String reminderId) async {
    CollectionReference reminders = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders');
    return reminders
        .doc(reminderId)
        .delete()
        .then((value) => print("Reminder Deleted"))
        .catchError((error) => print("Failed to delete reminder: $error"));
  }

  Future<void> updateReminder(
      String reminderId, String title, String description, int priority) async {
    CollectionReference reminders = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .collection('reminders');
    return reminders
        .doc(reminderId)
        .update({
          'title': title,
          'description': description,
          'priority': priority,
        })
        .then((value) => print("Reminder Updated"))
        .catchError((error) => print("Failed to update reminder: $error"));
  }

  void _showEditDialog(Reminder reminder) {
    String title = reminder.title;
    String description = reminder.description;
    int priority = reminder.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  title = value;
                },
                controller: TextEditingController(text: reminder.title),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                onChanged: (value) {
                  description = value;
                },
                controller: TextEditingController(text: reminder.description),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              DropdownButton<int>(
                value: priority,
                items: const [
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Very Important',
                        style: TextStyle(color: Colors.red)),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('Important',
                        style: TextStyle(color: Colors.orange)),
                  ),
                  DropdownMenuItem(
                    value: 3,
                    child: Text('Less Important',
                        style: TextStyle(color: Colors.green)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (title.isNotEmpty && description.isNotEmpty) {
                  updateReminder(reminder.id, title, description, priority);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            children: [
              Text(
                '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                style: GoogleFonts.adventPro(
                  textStyle: const TextStyle(color: Colors.white, fontSize: 50),
                ),
              ),
            ],
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
      body: StreamBuilder<List<Reminder>>(
        stream: fetchReminders(_currentUser.uid, widget.selectedDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reminders for this day.'));
          } else {
            return ListView(
              children: snapshot.data!.map((reminder) {
                Color priorityColor;
                switch (reminder.priority) {
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

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: priorityColor,
                    radius: 10,
                  ),
                  title: Text(reminder.title),
                  subtitle: Text(reminder.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog(reminder);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          deleteReminder(reminder.id);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String title = '';
              String description = '';
              int priority = 1;

              return AlertDialog(
                title: const Text('Add Reminder'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        title = value;
                      },
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      onChanged: (value) {
                        description = value;
                      },
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButton<int>(
                      value: priority,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('Very Important',
                              style: TextStyle(color: Colors.red)),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('Important',
                              style: TextStyle(color: Colors.orange)),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('Less Important',
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          priority = value!;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (title.isNotEmpty && description.isNotEmpty) {
                        addReminder(
                            title, description, widget.selectedDate, priority);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red,
      ),
    );
  }
}
