import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_keys.dart';
import '../models/summary_model.dart';
import 'feedback_repository.dart';

/// Generates an AI summary + score from a worker's feedback comments
/// (using Google's Gemini API) and persists it to the `summaries`
/// collection in Firestore.
///
/// If [ApiKeys.aiSummaryApiKey] is empty, summarization is silently
/// skipped — the rest of the app works fine without it.
class SummaryRepository {
  final _db = FirebaseFirestore.instance;
  final FeedbackRepository _feedbackRepository = FeedbackRepository();

  Future<SummaryModel?> getSummary(String workerName) async {
    final doc = await _db.collection('summaries').doc(workerName).get();
    if (!doc.exists) return null;
    return SummaryModel.fromMap(workerName, doc.data()!);
  }

  /// Regenerates and stores the AI summary for [workerName] based on all
  /// of its current feedback comments. Returns the new summary, or null if
  /// there's nothing to summarize or the AI key isn't configured.
  Future<SummaryModel?> refreshSummary(String workerName) async {
    if (ApiKeys.aiSummaryApiKey.isEmpty) {
      print('⚠️ AI summary API key not configured — skipping summarization.');
      return null;
    }

    final comments = await _feedbackRepository.loadFeedbackTexts(workerName);
    if (comments.isEmpty) return null;

    final result = await _summarise(workerName: workerName, comments: comments);
    if (result == null) return null;

    await _db.collection('summaries').doc(workerName).set({
      'worker': workerName,
      'avgRating': result.avgRating,
      'summary': result.summary,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return result;
  }

  Future<SummaryModel?> _summarise({
    required String workerName,
    required List<String> comments,
  }) async {
    final prompt = '''
You are given customer feedback comments for a worker named "$workerName".

Feedbacks:
${comments.map((c) => "- $c").join("\n")}

Task:
1) Write a 2-3 sentence summary highlighting professionalism, punctuality, and reliability.
2) Give an overall rating (0.0 to 10.0).

Return STRICT JSON only:
{"summary": "...", "score": 8.9}
''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${ApiKeys.aiSummaryApiKey}',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      if (response.statusCode != 200) {
        print('❌ AI summary API error: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      String textOutput = '';
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates.first['content'];
        final parts = content['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          textOutput = parts.first['text']?.toString() ?? '';
        }
      }

      final jsonText = _extractJson(textOutput);
      if (jsonText.isEmpty) return null;

      final parsed = jsonDecode(jsonText);
      final summary = (parsed['summary'] ?? '').toString();
      final score = double.tryParse(parsed['score']?.toString() ?? '') ?? 0.0;
      return SummaryModel(worker: workerName, summary: summary, avgRating: score);
    } catch (e) {
      print('❌ Summarization failed: $e');
      return null;
    }
  }

  String _extractJson(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      return text.substring(start, end + 1);
    }
    return '';
  }
}
