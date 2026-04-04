import 'package:equatable/equatable.dart';

class MyuserEntity extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? profileImageUrl;

  const MyuserEntity({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  static MyuserEntity fromDocument(Map<String, dynamic> doc) {
    return MyuserEntity(
      userId: doc['userId'],
      name: doc['name'],
      email: doc['email'],
      profileImageUrl: doc['profileImageUrl'],
    );
  }

  @override
  List<Object?> get props => [userId, name, email, profileImageUrl];
}
