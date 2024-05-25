import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/products.dart';

class ProductsDataTable extends StatefulWidget {
  final List<Product> products;
  final bool allowSelection;

  const ProductsDataTable({
    required this.products,
    required this.allowSelection,
    required Null Function(dynamic product, dynamic selected) onProductSelected,
    required bool isEditor,
    required List<Product> selectedProducts,
  });

  @override
  _ProductsDataTableState createState() => _ProductsDataTableState();
}

class _ProductsDataTableState extends State<ProductsDataTable> {
  final Set<Product> selectedProducts = {};

  void _onSelectedRow(bool selected, Product product) {
    if (widget.allowSelection) {
      setState(() {
        if (selected) {
          selectedProducts.add(product);
        } else {
          selectedProducts.remove(product);
        }
      });
    }
  }

  void _editSelectedProduct(BuildContext context, Product product) {
    final nameController = TextEditingController(text: product.name);
    final quantityController =
        TextEditingController(text: product.quantity.toString());
    final buyingPriceController =
        TextEditingController(text: product.buyingPrice.toString());
    final sellingPriceController =
        TextEditingController(text: product.sellingPrice.toString());
    final uomController = TextEditingController(text: product.uom);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: buyingPriceController,
                decoration: InputDecoration(labelText: "Buying Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sellingPriceController,
                decoration: InputDecoration(labelText: "Selling Price"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: uomController,
                decoration: InputDecoration(labelText: "Unit of Measure"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updatedProduct = Product(
                  name: nameController.text,
                  buyingPrice: double.parse(buyingPriceController.text),
                  sellingPrice: double.parse(sellingPriceController.text),
                  uom: uomController.text,
                  id: product.id,
                  quantity: int.parse(quantityController.text),
                );
                Provider.of<Products>(context, listen: false)
                    .updateProduct(product.id, updatedProduct);

                selectedProducts.clear();

                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedProduct() {
    if (selectedProducts.isNotEmpty) {
      final List<Product> productsToDelete = selectedProducts.toList();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Product"),
            content: Text(
                "Are you sure you want to delete ${productsToDelete.map((p) => p.name).join(', ')}?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<Products>(context, listen: false)
                      .deleteProducts(productsToDelete);

                  selectedProducts.clear();
                  setState(() {});
                  Navigator.pop(context);
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedProducts.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: selectedProducts.length == 1,
                child: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    if (selectedProducts.isNotEmpty) {
                      final product = selectedProducts.first;
                      _editSelectedProduct(context, product);
                    }
                  },
                ),
              ),
              Visibility(
                visible: selectedProducts.length > 0,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteSelectedProduct,
                ),
              ),
            ],
          ),
        Expanded(
          child: DataTable(
            columns: [
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Quantity")),
              DataColumn(label: Text("Buying Price")),
              DataColumn(label: Text("Selling Price")),
              DataColumn(label: Text("UOM")),
            ],
            rows: widget.products.map((product) {
              return DataRow(
                selected: selectedProducts.contains(product),
                onSelectChanged: (selected) =>
                    _onSelectedRow(selected!, product),
                cells: [
                  DataCell(Text(product.name)),
                  DataCell(Text(product.quantity.toString())),
                  DataCell(Text(product.buyingPrice.toString())),
                  DataCell(Text(product.sellingPrice.toString())),
                  DataCell(Text(product.uom!)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
