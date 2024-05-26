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
import '../providers/employees.dart';
import '../widgets/products_data_table.dart'; // Import EmployeeProvider

class StocksScreen extends StatefulWidget {
  static const routeName = '/stocksScreen';

  @override
  _StocksScreenState createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _selectedProducts = [];

  void _editProduct(Product product) {
    // Implement your edit product logic here
  }

  void _deleteSelectedProducts() {
    // Implement your delete selected products logic here
  }

  String _selectedRole = "Viewer";
  bool _isEditor = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("employee")
          .where("role", isEqualTo: "Editor")
          .get();
      setState(() {
        _isEditor = querySnapshot.docs.isNotEmpty;
        _isLoading = false;
      });
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
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    bool isUser = employeeProvider.employee?.role == "User";

    Future<bool> checkUserRole() async {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc['role'];
          return role != "User" && role != "Inactive";
        }
      }
      return false;
    }

    //final productProvider = Provider.of<Products>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stocks'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
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
        children: [
          Expanded(
            child:
                ListView(scrollDirection: Axis.horizontal, children: <Widget>[
              FutureBuilder<bool>(
                future: checkUserRole(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                        'assets/animations/loading.json',
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching user role'));
                  } else if (snapshot.hasData) {
                    bool allowSelection = snapshot.data!;
                    return StreamBuilder<List<Product>>(
                      stream: productProvider.productsStream,
                      builder: (context, productSnapshot) {
                        if (productSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: Lottie.asset(
                              'assets/animations/loading.json',
                            ),
                          );
                        } else if (productSnapshot.hasError) {
                          return Center(child: Text('Error fetching products'));
                        } else if (!productSnapshot.hasData ||
                            productSnapshot.data!.isEmpty) {
                          return Center(child: Text('No products available'));
                        } else {
                          final products = productSnapshot.data!
                              .where((product) => product.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase()))
                              .toList();
                          return ProductsDataTable(
                            products: products,
                            allowSelection: allowSelection,
                            onProductSelected: (product, selected) {
                              setState(() {
                                if (selected) {
                                  _selectedProducts.add(product);
                                } else {
                                  _selectedProducts.remove(product);
                                }
                              });
                            },
                            isEditor: allowSelection,
                            selectedProducts: _selectedProducts,
                          );
                        }
                      },
                    );
                  } else {
                    return Center(child: Text('Failed to determine user role'));
                  }
                },
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: checkUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox.shrink();
          } else if (snapshot.hasError) {
            return SizedBox.shrink();
          } else if (snapshot.hasData && snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductScreen()),
                );
              },
              child: Icon(Icons.add),
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
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
