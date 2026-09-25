class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String gender;
  final String birthdate;
  final String bio;
  final String? avatarUrl;
  final String createdAt;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.gender,
    required this.birthdate,
    required this.bio,
    required this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      username: json['username'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'],
    );
  }
}