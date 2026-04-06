import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'entities/entities.dart';
import 'models/models.dart';
import 'user_repo.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection(
    'Prompta-Users',
  );

  FirebaseUserRepo({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) => firebaseUser);
  }

  @override
  Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
      UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: myUser.email,
        password: password,
      );
      await user.user!.updateDisplayName(myUser.name);
      myUser = myUser.copywith(userId: user.user!.uid);
      return myUser;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> setUserData(MyUser myUser) async {
    try {
      await usersCollection
          .doc(myUser.userId)
          .set(myUser.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<MyUser> getUserData(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return MyUser.fromEntity(MyuserEntity.fromDocument(doc.data()!));
      }
      return MyUser.empty;
    } catch (e) {
      log(e.toString());
      return MyUser.empty;
    }
  }

  @override
  Stream<MyUser> userDataStream(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return MyUser.fromEntity(MyuserEntity.fromDocument(doc.data()!));
      }
      return MyUser.empty;
    });
  }

  @override
  Future<void> updateUserName(String userId, String newName) async {
    try {
      await usersCollection.doc(userId).update({'name': newName});
      await _firebaseAuth.currentUser?.updateDisplayName(newName);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String filePath) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      await usersCollection.doc(userId).update({
        'profileImageUrl': downloadUrl,
      });
      return downloadUrl;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
