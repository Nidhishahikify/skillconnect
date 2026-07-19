class FeedbackModel {
  final String worker;
  final String text;
  final double rating;
  final String timestamp;

  const FeedbackModel({
    required this.worker,
    required this.text,
    required this.rating,
    required this.timestamp,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      worker: map['worker'] ?? '',
      text: map['text'] ?? '',
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 0.0,
      timestamp: map['ts'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'worker': worker,
        'worker_lower': worker.toLowerCase(),
        'text': text,
        'rating': rating,
        'ts': timestamp,
      };
}
