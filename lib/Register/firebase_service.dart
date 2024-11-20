import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitness/Register/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerUser({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> saveUserData(UserCredential userCredential, UserModel userModel) async {
    String userId = userCredential.user!.uid;
    await _firestore.collection('usuarios').doc(userId).set(userModel.toMap());
  }
}
