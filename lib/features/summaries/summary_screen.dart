import 'package:flutter/material.dart';
import '../../repositories/feedback_repository.dart';
import '../../repositories/summary_repository.dart';

class SummariesScreen extends StatefulWidget {
  const SummariesScreen({super.key});

  @override
  State<SummariesScreen> createState() => _SummariesScreenState();
}

class _SummariesScreenState extends State<SummariesScreen> {
  final _workerController = TextEditingController();
  final _feedbackRepository = FeedbackRepository();
  final _summaryRepository = SummaryRepository();

  String? _summary;
  double? _rating;
  bool _loading = false;
  List<String> _feedbacks = [];

  @override
  void dispose() {
    _workerController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedbacks(String worker) async {
    setState(() => _loading = true);
    try {
      _feedbacks = await _feedbackRepository.loadFeedbackTexts(worker);
      final summary = await _summaryRepository.getSummary(worker);

      setState(() {
        _summary = summary?.summary;
        _rating = summary?.avgRating;
      });
    } catch (e) {
      print('⚠️ Error loading feedbacks: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _generateSummary(String worker) async {
    if (_feedbacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No feedbacks found for this worker')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _summaryRepository.refreshSummary(worker);

    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ AI summary not available (missing AI_SUMMARY_API_KEY).'),
          ),
        );
      }
    }

    setState(() {
      _summary = result?.summary ?? _summary;
      _rating = result?.avgRating ?? _rating;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Summaries'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _workerController,
              decoration: const InputDecoration(
                labelText: 'Enter worker name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final worker = _workerController.text.trim();
                    if (worker.isNotEmpty) _loadFeedbacks(worker);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Load'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final worker = _workerController.text.trim();
                    if (worker.isNotEmpty) _generateSummary(worker);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Summarize'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_loading)
              const CircularProgressIndicator()
            else if (_summary != null)
              Card(
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🧠 Summary',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 5),
                      Text(_summary ?? ''),
                      if (_rating != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '⭐ Rating: ${_rating!.toStringAsFixed(1)}/10',
                            style: const TextStyle(color: Colors.deepPurple),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
