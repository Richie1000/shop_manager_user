import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart' as pw;
import 'package:pdf/widgets.dart' as pw;
import 'package:shop_manager_user/widgets/custom_toast.dart';
import 'package:uuid/uuid.dart';

import '../providers/cart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

String getReceiptNumber() {
  // Get the current DateTime
  DateTime now = DateTime.now();

  // Define a list of month abbreviations
  const List<String> monthAbbreviations = [
    'Ja',
    'Fe',
    'Ma',
    'Ap',
    'Ma',
    'Ju',
    'Ju',
    'Au',
    'Se',
    'Oc',
    'No',
    'De'
  ];

  // Get the first two letters of the current month
  String month = monthAbbreviations[now.month - 1];

  // Format the current DateTime without hyphens, colons, and periods
  String formattedDateTime = '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';

  // Concatenate the month abbreviation with the formatted DateTime
  return '$month$formattedDateTime';
}

Future<Uint8List> generateAndSaveReceipt(
  List<CartItem> items,
  double totalAmount,
  String paymentMethod,
) async {
  try {
    // Initialize PDF document
    final pdf = pw.Document();

    // Generate receipt number
    final String receiptNumber = getReceiptNumber();

    // Add page to PDF
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Add receipt header
            pw.Text(
              'Receipt #$receiptNumber', // Adding receipt number
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Items:'),
            // Add items with date
            pw.ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final currentDate = DateTime.now();
                final formattedDate =
                    '${currentDate.day}/${currentDate.month}/${currentDate.year}'; // Format date as needed
                return pw.Text(
                  '${item.product.name} - ${item.quantity} x \$${item.product.sellingPrice.toStringAsFixed(2)} = \$${(item.quantity * item.product.sellingPrice).toStringAsFixed(2)} - $formattedDate',
                );
              },
            ),
            pw.Divider(),
            // Add total amount
            pw.Text('Total: \$${totalAmount.toStringAsFixed(2)}'),
            // Add payment method
            pw.Text('Payment Method: $paymentMethod'),
          ],
        ),
      ),
    );

    // Save PDF to local storage
    final pdfBytes = await pdf.save();

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$receiptNumber.pdf';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    // Save PDF to Firestore Storage
    final downloadUrl = await savePdfToStorage(receiptNumber, pdfBytes);

    // Add transaction to "receipts" collection on Firestore
    await addTransactionToFirestore(
        receiptNumber, items, totalAmount, paymentMethod, downloadUrl);

    print('PDF saved to local storage: $filePath');

    return pdfBytes; // Return PDF bytes
  } catch (e) {
    CustomToast(message: e.toString());
    rethrow; // Rethrow the caught exception
  }
}

Future<String> savePdfToStorage(
    String receiptNumber, Uint8List pdfBytes) async {
  // Save PDF to Firestore Storage

  final storageRef =
      FirebaseStorage.instance.ref().child('receipts/$receiptNumber.pdf');
  await storageRef.putData(pdfBytes);
  final downloadUrl = await storageRef.getDownloadURL();
  print('PDF saved to: $downloadUrl');
  return downloadUrl;
}

Future<void> addTransactionToFirestore(
  String receiptNumber,
  List<CartItem> items,
  double totalAmount,
  String paymentMethod,
  String pdfDownloadUrl,
) async {
  final firestore = FirebaseFirestore.instance;

  // Convert items to a list of maps
  final List itemsData = items.map((item) => item.toMap()).toList();

  // Add transaction to Firestore
  await firestore.collection('receipts').doc(receiptNumber).set({
    'items': itemsData,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'date': DateTime.now(),
    'pdfDownloadUrl': pdfDownloadUrl, // Add download URL of PDF
  });
}
