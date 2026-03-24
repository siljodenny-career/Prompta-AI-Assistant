import 'package:equatable/equatable.dart';

class MyuserEntity extends Equatable {
  final String userId;
  final String name;
  final String email;

  const MyuserEntity({
    required this.userId,
    required this.name,
    required this.email,
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
    };
  }

  static MyuserEntity fromDocument(Map<String, dynamic> doc) {
    return MyuserEntity(
      userId: doc['userId'],
      name: doc['name'],
      email: doc['email'],
    );
  }

  @override
  List<Object?> get props => [userId, name, email];
}
