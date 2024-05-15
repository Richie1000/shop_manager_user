import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_manager_user/providers/auth.dart';
import 'package:shop_manager_user/screens/auth_screen.dart';
import './screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Your App Name',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return HomePage();
            } else {
              return AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
