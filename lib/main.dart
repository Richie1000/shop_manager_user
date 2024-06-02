import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shop_manager_user/models/employee.dart';
import 'package:shop_manager_user/providers/auth.dart' as au;
import 'package:shop_manager_user/screens/auth_screen.dart';
import 'package:shop_manager_user/screens/stocks_screen.dart';
import './screens/home.dart';
import 'providers/cart.dart';
import 'providers/employees.dart';
import 'providers/products.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => au.AuthProvider()),
        ChangeNotifierProvider(create: (context) => Products()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => EmployeeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Arturo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white, // Default background for TextFormField
          ),
          useMaterial3: true,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return AuthScreen();
          } else {
            // Schedule fetchEmployee after the build is complete
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Provider.of<EmployeeProvider>(context, listen: false)
                  .fetchEmployee();
            });
            return HomePage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
