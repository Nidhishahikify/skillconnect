class WorkerModel {
  final String name;
  final String email;
  final String skill;
  final String experience;
  final String contact;
  final String availability;
  final String location;

  const WorkerModel({
    required this.name,
    required this.email,
    this.skill = '',
    this.experience = '',
    this.contact = '',
    this.availability = '',
    this.location = '',
  });

  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      skill: map['skill'] ?? '',
      experience: map['experience']?.toString() ?? '',
      contact: map['contact'] ?? '',
      availability: map['availability']?.toString() ?? '',
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'skill': skill,
        'experience': experience,
        'contact': contact,
        'availability': availability,
        'location': location,
        'isWorker': true,
      };
}
