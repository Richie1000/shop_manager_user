import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:shop_manager_user/screens/loading_screen.dart';
import 'package:shop_manager_user/widgets/custom_toast.dart';
import '../providers/cart.dart';
import '../utils/pdf_generation.dart';

class CheckoutScreen extends StatefulWidget {
  final String paymentMethod;

  CheckoutScreen({required this.paymentMethod});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    //bool isLoading = false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      backgroundColor: Colors.white,
      body: Stack(children: [
        Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  final item = cart.items[index];
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                        '${item.quantity} x ₵${item.product.sellingPrice.toStringAsFixed(2)}'),
                    trailing: Text(
                        '₵${(item.quantity * item.product.sellingPrice).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Total: ₵${cart.totalAmount.toStringAsFixed(2)}'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                try {
                  final pdf = await generateAndSaveReceipt(cart.items,
                      cart.totalAmount, widget.paymentMethod, context);
                  await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdf);
                  cart.clear();
                } catch (error) {
                  print('This is the error' + error.toString());
                  CustomToast(
                    message: error.toString(),
                  );
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              child: Text('Paid'),
            ),
          ],
        ),
        if (isLoading) Center(child: LoadingScreen())
      ]),
    );
  }
}
