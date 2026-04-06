import 'package:firebase_auth/firebase_auth.dart';


import 'models/models.dart';

abstract class UserRepository {

  Stream<User?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);
  Future<void> setUserData(MyUser myUser);
  Future<void> signIn(String email, String password);
  Future<void> signOut();
  Future<MyUser> getUserData(String userId);
  Stream<MyUser> userDataStream(String userId);
  Future<void> updateUserName(String userId, String newName);
  Future<String> uploadProfileImage(String userId, String filePath);
}