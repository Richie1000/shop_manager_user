
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserState with ChangeNotifier {
  bool _isActive = false;

  bool get isActive => _isActive;

  void setActive() {
    _isActive = true;
    notifyListeners();
  }

  void setInactive() {
    _isActive = false;
    notifyListeners();
  }

  void toggleActive() {
    _isActive = !_isActive;
    notifyListeners();
  }

  Future<void> checkActiveStatus(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot employeeDoc = snapshot.docs.first;
        bool active = employeeDoc.get("active");
        if (!active) {
          setInactive();
        } else {
          setActive();
        }
      }
    } catch (e) {
      print("Error checking active status: $e");
    }
  }
}