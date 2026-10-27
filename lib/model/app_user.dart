import 'model_utils.dart';

class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isOrganizer => role == 'organizer';

  String get inisial {
    final bagian = name.trim().split(RegExp(r'\s+'));
    if (bagian.isEmpty || bagian.first.isEmpty) return 'G';
    if (bagian.length == 1) return bagian.first.substring(0, 1).toUpperCase();
    return (bagian.first.substring(0, 1) + bagian.last.substring(0, 1))
        .toUpperCase();
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: readInt(json['id']),
      name: readText(json['name'], 'Pengguna'),
      email: readText(json['email']),
      role: readText(json['role'], 'user'),
    );
  }
}
