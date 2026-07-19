import 'package:flutter/material.dart';
import '../../repositories/feedback_repository.dart';
import '../../repositories/summary_repository.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _controller = TextEditingController();
  final _workerController = TextEditingController();
  final _feedbackRepository = FeedbackRepository();
  final _summaryRepository = SummaryRepository();

  List<Map<String, dynamic>> _list = [];
  bool _loading = false;
  double _rating = 5.0; // ⭐ default middle rating

  Future<void> _loadFor(String name) async {
    setState(() => _loading = true);
    final items = await _feedbackRepository.loadFeedbacks(name);
    setState(() {
      _list = items;
      _loading = false;
    });
  }

  Future<void> _submit(String name) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final entry = {
      'text': text,
      'rating': _rating,
      'ts': DateTime.now().toIso8601String(),
      'worker': name,
      'worker_lower': name.toLowerCase(),
    };

    await _feedbackRepository.addFeedback(name, entry);
    _controller.clear();
    await _loadFor(name);

    // 🧠 Refresh AI summary (no-op if AI key isn't configured)
    await _summaryRepository.refreshSummary(name);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Feedback saved successfully!')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _workerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _workerController,
              decoration: const InputDecoration(
                labelText: 'Worker name (for feedback)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_workerController.text.trim().isNotEmpty) {
                      _loadFor(_workerController.text.trim());
                    }
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
                    _workerController.clear();
                    setState(() => _list = []);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Write feedback',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Text('Rate this worker: ${_rating.toStringAsFixed(1)} / 10'),
                Slider(
                  value: _rating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: Colors.deepPurple,
                  label: _rating.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _rating = v),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                final name = _workerController.text.trim();
                if (name.isNotEmpty) _submit(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _list.length,
                      itemBuilder: (context, i) {
                        final it = _list[i];
                        final dt = DateTime.tryParse(it['ts'] ?? '')
                                ?.toLocal()
                                .toString() ??
                            '';
                        return Card(
                          child: ListTile(
                            title: Text(it['text'] ?? ''),
                            subtitle: Text('⭐ ${it['rating'] ?? '-'}  |  $dt'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
