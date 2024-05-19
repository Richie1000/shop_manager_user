import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:dio/dio.dart';
import 'package:shop_manager_user/screens/loading_screen.dart';
import 'package:shop_manager_user/widgets/custom_toast.dart';

class ReceiptScreen extends StatefulWidget {
  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  Future<void> _searchAndOpenPdf(String receiptId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('receipts')
          .doc(receiptId)
          .get();

      if (docSnapshot.exists) {
        final pdfDownloadUrl = docSnapshot['pdfDownloadUrl'];
        final fileName = '$receiptId.pdf';
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';

        print("Found Receipts!");
        print('The download Url: $pdfDownloadUrl');

        await _downloadFile(pdfDownloadUrl, filePath);

        print("Downloaded Receipts");
        await OpenFile.open(filePath);
      } else {
        CustomToast(message: "Receipt Not Found!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadFile(String url, String filePath) async {
    final dio = Dio();
    await dio.download(url, filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Receipt Search'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter Receipt ID',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        final receiptId = _searchController.text.trim();
                        if (receiptId.isNotEmpty) {
                          _searchAndOpenPdf(receiptId);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) LoadingScreen(),
        ],
      ),
    );
  }
}
