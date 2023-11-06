import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'dart:convert';
//import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;

class Second extends StatefulWidget {
  final String staffid;
  final String category;
  const Second({Key? key, required this.staffid, required this.category})
      : super(key: key);

  @override
  _SecondState createState() => _SecondState();
}

class _SecondState extends State<Second> {
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  String? code;
  bool isScanning = false;
  bool isDataReadyToSend = false;

  void startScanning() {
    _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
      context: context,
      onCode: (scannedCode) {
        setState(() {
          code = scannedCode;
          isScanning = false;
          isDataReadyToSend = true;
        });
      },
    );
    isScanning = true;
  }

  Future<void> sendtoserver(data) async {
    const url = 'https://dicoman.dist.ac.in/api/candidate';
    final credentials = {
      //'category': widget.category,
      //'staff_id': widget.staffid,
      'cand_id': data,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    final body = json.encode(credentials);

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      print("succesful");
      print(response.body);
      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData['candidate']);
    } else {
      throw Exception('Failed to send data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.teal,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.teal[200],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (code != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Scanned Result",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        code!,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              isScanning
                  ? ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isScanning = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        startScanning();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Button color
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                      ),
                      child: Text(
                        code == null ? "Click me" : "Scan Again",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 20),
              if (isDataReadyToSend)
                ElevatedButton(
                  onPressed: () {
                    if (code != null) {
                      sendtoserver(code!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                  ),
                  child: const Text(
                    "Send to Server",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
