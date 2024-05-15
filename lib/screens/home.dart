import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../widgets/grid_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final numColumns = (screenWidth / 200).round();
    final gridTitle = ["Sale", "Stats", "Stocks", "Check Receipt", "Logout"];
    final assetName = ["cart", "stats", "stock", "receipts", "logout"];

    Future<void> logout() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.signOut();
    }

    pushSalesScreen() {
      //pushScreen
    }

    pushStatsScreen() {
      //pushScreen
    }

    pushStocksScreen() {
      //pushScreen
    }

    pushReceiptsScreen() {
      //pushScreen
    }

    List<Function()> listOfFunctions = [
      pushSalesScreen,
      pushStatsScreen,
      pushStocksScreen,
      pushReceiptsScreen,
      logout,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: numColumns,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: gridTitle.length,
        itemBuilder: (context, index) {
          return GridItem(
            title: gridTitle[index],

            //subtitle: '',
            //icon: Icon(Icons.)
            onTap: () {
              // Call the corresponding function from listOfFunctions
              listOfFunctions[index]();
            },
            lottieAsset: 'assets/animations/${assetName[index]}.json',
          );
        },
      ),
    );
  }
}