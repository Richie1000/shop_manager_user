import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_user/screens/loading_screen.dart';
import '../models/product.dart';
import '../providers/products.dart';

class StocksScreen extends StatefulWidget {
  static const routeName = '/stocksScreen';

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);

    late StreamSubscription _subscription;

    @override
    void initState() {
      super.initState();
      // Subscribe to stream
      _subscription = productProvider.productsStream.listen((data) {
        // Handle stream data
      });
    }

    @override
    void dispose() {
      // Dispose of stream subscription
      _subscription.cancel();
      super.dispose();
    }

    Future<void> _refreshProducts() async {
      await productProvider.fetchProducts();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: StreamBuilder<List<Product>>(
          stream: productProvider.productsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Center(child: Text('Error fetching products'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No products available'));
            } else {
              final products = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Selling Price')),
                    DataColumn(label: Text('Buying Price')),
                    // DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('UOM')),
                  ],
                  rows: products.map((product) {
                    return DataRow(cells: [
                      DataCell(Text(product.name)),
                      DataCell(
                          Text('\$${product.sellingPrice.toStringAsFixed(2)}')),
                      DataCell(
                          Text('\$${product.buyingPrice.toStringAsFixed(2)}')),
                      // DataCell(Text(product.quantity.toString())),
                      DataCell(Text(product.uom)),
                    ]);
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
