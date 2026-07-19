import 'package:flutter/material.dart';

/// Card showing a single booking with status + accept/reject actions
/// (used on the worker dashboard).
class BookingCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String date;
  final String time;
  final String status; // pending / accepted / rejected
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const BookingCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.date,
    required this.time,
    required this.status,
    this.onAccept,
    this.onReject,
  });

  Color get _statusColor {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Color get _statusBackground {
    switch (status) {
      case 'accepted':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      default:
        return Colors.yellow.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('📅 $date'),
            Text('⏰ $time'),
            Text('📧 $userEmail'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: $status',
                style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold),
              ),
            ),
            if (status == 'pending' && onAccept != null && onReject != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: onAccept,
                    child: const Text('ACCEPT'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, foregroundColor: Colors.white),
                    onPressed: onReject,
                    child: const Text('REJECT'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
