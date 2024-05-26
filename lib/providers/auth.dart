import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_manager_user/widgets/custom_toast.dart';

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
          msg:
              "Email not found in employees list. Contact Adminstrator to be able to register",
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

      // Add user details to Firestore collection
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': email,
        'username': fullName,
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

  Future<void> updateUserWithRole(
      String userId, String email, String fullName) async {
    try {
      // Fetch the role from the employees collection where email matches
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        // Assume there's only one document that matches the email
        DocumentSnapshot employeeDoc = employeeSnapshot.docs.first;

        // Get the role field from the employee document
        String role = employeeDoc['role'];

        // Set the data in the users collection, including the role field
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': email,
          'username': fullName,
          'role': role,
        });

        print('User updated with role successfully');
      } else {
        print('Employee document with the provided email does not exist');
      }
    } catch (e) {
      print('Failed to update user with role: $e');
    }
  }
}
