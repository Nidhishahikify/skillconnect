class BookingModel {
  final String workerName;
  final String workerEmail;
  final String userName;
  final String userEmail;
  final String date;
  final String time;
  final String timestamp;
  final String status;

  const BookingModel({
    required this.workerName,
    required this.workerEmail,
    required this.userName,
    required this.userEmail,
    required this.date,
    required this.time,
    required this.timestamp,
    this.status = 'pending',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      workerName: map['workerName'] ?? '',
      workerEmail: map['workerEmail'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      timestamp: map['timestamp'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'workerName': workerName,
        'workerEmail': workerEmail,
        'userName': userName,
        'userEmail': userEmail,
        'date': date,
        'time': time,
        'timestamp': timestamp,
        'status': status,
      };
}
