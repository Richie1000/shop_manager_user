import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shop_manager_user/screens/add_product_screen.dart';
import 'package:shop_manager_user/screens/loading_screen.dart';
import 'package:shop_manager_user/widgets/custom_toast.dart';
import '../models/product.dart';
import '../providers/products.dart';

import '../widgets/products_data_table.dart'; // Import EmployeeProvider

class StocksScreen extends StatefulWidget {
  static const routeName = '/stocksScreen';

  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final String _searchQuery = '';
  final List<Product> _selectedProducts = [];

  void _editProduct(Product product) {
    // Implement your edit product logic here
  }

  void _deleteSelectedProducts() {
    // Implement your delete selected products logic here
  }

  String _selectedRole = "Viewer";
  bool _isEditor = false;
  bool _isLoading = true;
  String role = "";

  @override
  void initState() {
    super.initState();
    _checkRole();
    print(role);
  }

  Future<void> _checkRole() async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Query the employees collection to get the document with the matching user ID
        DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        // Check if the document exists
        if (employeeDoc.exists) {
          // Get the role field from the document
          role = employeeDoc.get('role');

          setState(() {
            _isEditor = role == 'Editor';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isEditor = false;
            _isLoading = false;
          });
        }
      } else {
        // Handle the case where there is no logged-in user
        setState(() {
          _isEditor = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      CustomToast(message: e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(productProvider),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: [
          Expanded(
            child:
                ListView(scrollDirection: Axis.horizontal, children: <Widget>[
              StreamBuilder<List<Product>>(
                stream: productProvider.productsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingScreen());
                  } else if (snapshot.hasError) {
                    return const Align(
                      alignment: Alignment.center,
                      child: Text('fetching Error!'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Align(
                      alignment: Alignment.center,
                      child: Text('No products available'),
                    );
                  } else {
                    final products = snapshot.data!
                        .where((product) => product.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();
                    return ProductsDataTable(
                      products: products,
                      onProductSelected: (product, selected) {
                        setState(() {
                          if (selected) {
                            _selectedProducts.add(product);
                          } else {
                            _selectedProducts.remove(product);
                          }
                        });
                      },

                      isEditor: _isEditor, // Pass isEditor to ProductsDataTable
                      selectedProducts: _selectedProducts,
                    );
                  }
                },
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: _isEditor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  final Products productProvider;

  ProductSearchDelegate(this.productProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: productProvider.productsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(product.name),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'Selling Price: \$${product.sellingPrice.toStringAsFixed(2)}'),
                        Text(
                            'Buying Price: \$${product.buyingPrice.toStringAsFixed(2)}'),
                        Text('Quantity: ${product.quantity}'),
                        Text('UOM: ${product.uom}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
