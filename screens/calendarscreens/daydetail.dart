// day_details_screen.dart

// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/widgets/appbar.dart';
import 'package:my_app/widgets/side_menu.dart';
import 'reminder.dart'; // Add this import

class DayDetailsScreen extends StatefulWidget {
  final DateTime selectedDate;

  DayDetailsScreen({required this.selectedDate});

  @override
  _DayDetailsScreenState createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  late User _currentUser;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
          'isChecked': false,
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

  Future<void> updateReminder(String reminderId, String title,
      String description, int priority, bool isChecked) async {
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
          'isChecked': isChecked,
        })
        .then((value) => print("Reminder Updated"))
        .catchError((error) => print("Failed to update reminder: $error"));
  }

  void _showEditDialog(Reminder reminder) {
    String title = reminder.title;
    String description = reminder.description;
    int priority = reminder.priority;
    bool isChecked = reminder.isChecked; // Güncel isChecked değeri

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Completed'),
                  Switch(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value;
                      });
                    },
                  ),
                ],
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
                  updateReminder(
                      reminder.id, title, description, priority, isChecked);
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
      key: scaffoldKey,
      appBar: CustomAppBar(
        title:
            '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
        autoback: true,
        scaffoldKey: scaffoldKey,
      ),
      endDrawer: CustomSideMenu(auth: _auth),
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
                    backgroundColor:
                        reminder.isChecked ? Colors.grey : priorityColor,
                    radius: 10,
                  ),
                  title: Text(reminder.title,
                      style: TextStyle(
                          decoration: reminder.isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none)),
                  subtitle: Text(
                    reminder.description,
                    style: TextStyle(
                        decoration: reminder.isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              updateReminder(
                                  reminder.id,
                                  reminder.title,
                                  reminder.description,
                                  reminder.priority,
                                  !reminder.isChecked);
                            });
                          },
                          icon: Icon(
                            Icons.check_circle,
                            color:
                                reminder.isChecked ? Colors.green : Colors.grey,
                          )),
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
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
