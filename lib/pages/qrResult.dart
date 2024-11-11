import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smmic/pages/QRcode.dart';

class QRResult extends StatelessWidget {
  final String code;
  final Function() closeScreen;

  const QRResult({super.key, required this.code, required this.closeScreen});

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define responsive padding and sizes
    final double padding = screenWidth * 0.05; // 5% of screen width
    final double qrSize = screenWidth * 0.5; // 50% of screen width
    final double buttonWidth = screenWidth * 0.7; // 70% of screen width
    final double titleFontSize = screenWidth * 0.07; // 7% of screen width
    final double buttonFontSize = screenWidth * 0.05; // 5% of screen width
    final double textFontSize = screenWidth * 0.04; // 4% of screen width
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const QRcode();
              }));
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        centerTitle: true,
        title: const Text(
          'Scanned Result',
          style: TextStyle(
              color: Colors.black, fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            QrImageView(
              data: "",
              size: 300,
              version: QrVersions.auto,
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height
            const Text(
              "Scanned QR",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            SizedBox(
              width: buttonWidth,
              height: screenHeight * 0.05, // 5% of screen height

              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 59, 57, 56)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                  },
                  child: const Text(
                    "Copy",
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
