import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/pages/qrResult.dart';
import 'package:smmic/providers/theme_provider.dart';

class QRcode extends StatefulWidget {
  const QRcode({super.key});

  @override
  State<QRcode> createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcode> {
  bool isFrontCameraOn = false;
  bool isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    isScanCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.watch<UiProvider>().isDark
            ? const Color.fromRGBO(45, 59, 89, 1)
            : const Color.fromRGBO(255, 255, 255, 1),
        leading: IconButton(
          style: ButtonStyle(
            iconSize: const WidgetStatePropertyAll(30),
            iconColor: WidgetStatePropertyAll(context.watch<UiProvider>().isDark
                ? Colors.white
                : Colors.black),
          ),
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
        ),
        centerTitle: true,
        title: Text(
          'QR CODE',
          style: TextStyle(
              color: context.watch<UiProvider>().isDark
                  ? Colors.white
                  : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: context.watch<UiProvider>().isDark
          ? const Color.fromRGBO(45, 59, 89, 1)
          : Colors.white,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Place the QR code in designated area',
                  style: TextStyle(
                      color: context.watch<UiProvider>().isDark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'let the scan do the magic - It starts on it own!',
                  style: TextStyle(
                      color: context.watch<UiProvider>().isDark
                          ? Colors.white
                          : Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w100),
                )
              ],
            )),
            SizedBox(
              height: 20,
            ),
            Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    MobileScanner(
                      onDetect: (capture) {
                        final barcode = capture.barcodes.first;
                        if (!isScanCompleted) {
                          isScanCompleted = true;
                          String code = barcode.rawValue ?? "---";
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return QRResult(
                                code: code, closeScreen: closeScreen);
                          }));
                        }
                      },
                    ),
                    QRScannerOverlay(
                      overlayColor: Colors.black26,
                      borderColor: Colors.white,
                      borderRadius: 20,
                      borderStrokeWidth: 10,
                      scanAreaWidth: 250,
                      scanAreaHeight: 250,
                    )
                  ],
                )),
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '|Scan properly to see result|',
                  style: TextStyle(
                      color: context.watch<UiProvider>().isDark
                          ? Colors.white
                          : Colors.black),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
