class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String notificationToken;

  User({required this.id, required this.firstName, required this.lastName, required this.email, required this.role, required this.notificationToken});

  factory User.fromJson(Map<String, dynamic> json) => User(
      id: json["id"] ?? 0,
      firstName: json["firstName"] ?? '',
      lastName: json["lastName"] ?? '',
      email: json["email"] ?? '',
      role: json["role"] ?? '',
      notificationToken: json["notification_token"] ?? '');
}
