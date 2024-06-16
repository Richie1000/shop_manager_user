import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user; // Change to nullable

  User? get user => _user; // Change to nullable

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      notifyListeners();
      return _user;
    } catch (error) {
      //print("this is the error" + error.toString());
      String modifiedErrorMessage =
          error.toString().replaceAll("firebase_auth", "");
      Fluttertoast.showToast(
        msg: modifiedErrorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      return null;
    }
  }

Future<User?> registerWithEmailAndPassword(
    String email, String password, String fullName) async {
  try {
    // Check if the email exists in the "employees" collection
    bool employeeExists = await checkEmployeeExists(email);
    if (!employeeExists) {
      Fluttertoast.showToast(
        msg: "Email not found in employees list. Contact Administrator to be able to register",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      return null;
    }

    // If email exists, proceed with registration
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = result.user;
    final snapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('email', isEqualTo: email)
      .get();

    DocumentSnapshot employeeDoc = snapshot.docs.first;
    String role = employeeDoc.get("role");
    bool active = employeeDoc.get("active"); // Ensure the 'active' field is retrieved as a boolean

    // Add user details to Firestore collection
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'email': email,
      'username': fullName,
      'role': role,
      'active': active
    });

    notifyListeners();
    return user;
  } catch (error) {
    String modifiedErrorMessage =
        error.toString().replaceAll("firebase_auth", "");
    Fluttertoast.showToast(
      msg: modifiedErrorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
    return null;
  }
}
Future<bool> checkEmployeeExists(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('employees')
      .where('email', isEqualTo: email)
      .get();
  return snapshot.docs.isNotEmpty;
}
  Future signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
