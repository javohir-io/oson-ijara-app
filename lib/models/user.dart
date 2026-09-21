class AppUser {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
