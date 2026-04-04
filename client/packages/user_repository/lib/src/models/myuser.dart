import 'package:equatable/equatable.dart';

import '../entities/entities.dart';



class MyUser extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String? profileImageUrl;

  const MyUser({
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  static const MyUser empty = MyUser(
    userId: '',
    name: '',
    email: '',
  );

  MyUser copywith({
    String? userId,
    String? name,
    String? email,
    String? profileImageUrl,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  MyuserEntity toEntity() {
    return MyuserEntity(
      userId: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
    );
  }

  static MyUser fromEntity(MyuserEntity entity) {
    return MyUser(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
    );
  }

  @override
  List<Object?> get props => [userId, name, email, profileImageUrl];
}
