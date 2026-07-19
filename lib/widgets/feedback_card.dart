import 'package:flutter/material.dart';

/// Card showing a single piece of feedback text with its rating & date.
class FeedbackCard extends StatelessWidget {
  final String text;
  final String rating;
  final String formattedTime;

  const FeedbackCard({
    super.key,
    required this.text,
    required this.rating,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(text, style: const TextStyle(fontSize: 15)),
        subtitle: Text(formattedTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ],
        ),
      ),
    );
  }
}
