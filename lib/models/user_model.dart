class UserModel {
  final String name;
  final String email;
  final bool isWorker;

  const UserModel({
    required this.name,
    required this.email,
    this.isWorker = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isWorker: map['isWorker'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'isWorker': isWorker,
      };
}
