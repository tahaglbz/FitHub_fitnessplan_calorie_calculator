// reminder.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final int priority;
  final bool isChecked;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
    required this.isChecked,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      priority: data['priority'] ?? 0,
      isChecked: data['isChecked'] ?? false,
    );
  }
}
