class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImage,
  });

  bool get isAdmin => role == UserRole.admin;
}

enum UserRole { user, admin }
