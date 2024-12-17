import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/pages/QRcode.dart';
import 'package:smmic/providers/theme_provider.dart';

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
        automaticallyImplyLeading: false,
        backgroundColor: context.watch<UiProvider>().isDark
            ? const Color.fromRGBO(45, 59, 89, 1)
            : Colors.white,
        centerTitle: true,
        title: Text(
          'Scanned Result',
          style: TextStyle(
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(45, 59, 89, 1)
          : Colors.white,
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
            Text(
              "Scanned QR",
              style: TextStyle(
                  color: context.watch<UiProvider>().isDark
                      ? Colors.white
                      : Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Text(
              code,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.watch<UiProvider>().isDark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 15),
            ),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
          ],
        ),
      ),
    );
  }
}
