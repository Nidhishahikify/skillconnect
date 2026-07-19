import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkerFeedbackScreen extends StatelessWidget {
  final String workerName;
  const WorkerFeedbackScreen({super.key, required this.workerName});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('$workerName - All Feedbacks'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('feedbacks').where('worker', isEqualTo: workerName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          // If no results from 'worker', try 'worker_lower'
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('feedbacks')
                  .where('worker_lower', isEqualTo: workerName.toLowerCase())
                  .snapshots(),
              builder: (context, secondSnap) {
                if (secondSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                if (!secondSnap.hasData || secondSnap.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No feedback available.',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

                return _buildFeedbackList(secondSnap.data!.docs);
              },
            );
          }

          return _buildFeedbackList(snapshot.data!.docs);
        },
      ),
    );
  }

  Widget _buildFeedbackList(List<QueryDocumentSnapshot> docs) {
    double totalRating = 0;
    int count = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ratingValue = data.containsKey('rating')
          ? double.tryParse(data['rating']?.toString() ?? '0') ?? 0.0
          : 0.0;
      if (ratingValue > 0) {
        totalRating += ratingValue;
        count++;
      }
    }
    final avgRating = count > 0 ? (totalRating / count).toStringAsFixed(1) : 'N/A';

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.deepPurple.shade50,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 26),
              const SizedBox(width: 6),
              Text(
                'Average Rating: $avgRating / 10',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              if (count > 0)
                Text('  ($count reviews)', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final f = docs[i].data() as Map<String, dynamic>;
              final text = f['text'] ?? '';
              final rating =
                  f.containsKey('rating') ? f['rating']?.toString() ?? 'N/A' : 'No rating yet';
              final time = f['ts'] ?? '';

              final formattedTime =
                  DateTime.tryParse(time)?.toLocal().toString().split('.')[0] ?? time;

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
                      Text(rating,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
