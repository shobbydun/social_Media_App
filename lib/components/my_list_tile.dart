import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure intl is added to your pubspec.yaml

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Timestamp timestamp;
  final Widget? trailing; // Added trailing parameter
  final int? maxLines;

  const MyListTile({
    super.key,
    required this.subtitle,
    required this.title,
    required this.timestamp,
    this.trailing,
    this.maxLines // Initialize trailing parameter
  });

  @override
  Widget build(BuildContext context) {
    // Format timestamp into readable date
    String formattedDate = DateFormat.yMMMd().format(timestamp.toDate());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 4), // Shadow position
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          subtitle: Text(
            '$subtitle\n$formattedDate',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          leading: Icon(
            Icons.person, // Example icon, replace as needed
            color: Theme.of(context).colorScheme.primary,
          ),
          trailing: trailing, // Use trailing widget
        ),
      ),
    );
  }
}
