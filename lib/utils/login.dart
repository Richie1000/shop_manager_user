import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_toast.dart';

// Function to check if the username and email are unique in the Firestore collection
Future<void> signUpWithEmailAndPassword(
  String email,
  String password,
  String username,
) async {
  try {
    // Check if the username is already taken
    final usernameCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (usernameCheck.docs.isNotEmpty) {
      // Username already exists, show toast message
      showToast('Username is already taken');
      return;
    }

    // Check if the email is already registered
    final emailCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (emailCheck.docs.isNotEmpty) {
      // Email already exists, show toast message
      showToast('Email is already registered');
      return;
    }

    // Create the user with email and password
    final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user ID
    final userId = userCredential.user!.uid;

    // Store additional user data in Firestore
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': email,
      'username': username,
      // Add other user data as needed
    });

    // Update authentication status
    // For example, you might want to set a global variable or notify listeners
    // that the user is logged in

    // Print user logged in to the console
    print('User logged in: ${userCredential.user!.email}');
  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuth errors
    if (e.code == 'weak-password') {
      showToast('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      showToast('The account already exists for that email.');
    } else {
      showToast('Error: ${e.message}');
    }
  } catch (e) {
    // Handle other errors
    showToast('Error: $e');
  }
}

// Function to display a custom toast message
void showToast(String message) {
  CustomToast(message: message);
}
