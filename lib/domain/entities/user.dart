import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final String preferredLanguage;
  final bool isDarkMode;

  const User({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.preferredLanguage = 'en',
    this.isDarkMode = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? preferredLanguage,
    bool? isDarkMode,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        preferredLanguage,
        isDarkMode,
      ];
}
