class SummaryModel {
  final String worker;
  final String summary;
  final double avgRating;

  const SummaryModel({
    required this.worker,
    required this.summary,
    required this.avgRating,
  });

  factory SummaryModel.fromMap(String worker, Map<String, dynamic> map) {
    return SummaryModel(
      worker: worker,
      summary: map['summary']?.toString() ?? '',
      avgRating: double.tryParse(map['avgRating']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'worker': worker,
        'summary': summary,
        'avgRating': avgRating,
      };
}
