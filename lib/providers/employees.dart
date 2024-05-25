import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop_manager_user/models/employee.dart';

class EmployeeProvider with ChangeNotifier {
  Employee? _employee;
  bool _isLoading = false;

  Employee? get employee => _employee;
  bool get isLoading => _isLoading;

  Future<void> fetchEmployee() async {
    _isLoading = true;
    notifyListeners();

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('employees')
            .doc(uid)
            .get();

        if (doc.exists) {
          _employee = Employee.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id);
        } else {
          print('Employee not found for UID: $uid');
        }
      }
    } catch (error) {
      print('Error fetching employee: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearEmployee() {
    _employee = null;
    notifyListeners();
  }
}
