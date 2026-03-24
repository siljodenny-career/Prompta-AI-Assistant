import 'package:equatable/equatable.dart';
import 'package:user_respository/src/entities/myuser_entity.dart';

class MyUser extends Equatable {
  final String userId;
  final String name;
  final String email;

  const MyUser({
    required this.userId,
    required this.name,
    required this.email,
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
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  
  MyuserEntity toEntity(){
    return MyuserEntity(
      userId: userId,
      name: name,
      email: email,
    );
  }

  static MyUser fromEntity(MyuserEntity entity){
    return MyUser(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
    );
  }

  @override
  List<Object?> get props => [];
}
