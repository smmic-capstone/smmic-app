import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:smmic/pages/qrResult.dart';

class QRcode extends StatefulWidget {
  const QRcode({super.key});

  @override
  State<QRcode> createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcode> {
  bool isFlashOn = false;
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
        backgroundColor: Colors.white,
        leading: IconButton(
          style: const ButtonStyle(
            iconSize: WidgetStatePropertyAll(30),
            iconColor: WidgetStatePropertyAll(Colors.black),
          ),
          onPressed: () {},
          icon: const Icon(Icons.qr_code_scanner),
        ),
        centerTitle: true,
        title: const Text(
          'QR CODE',
          style: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isFlashOn = !isFlashOn;
                });
              },
              icon: Icon(
                Icons.flash_on,
                color: isFlashOn ? Colors.white : Colors.black,
              )),
          IconButton(
              onPressed: () {
                setState(() {
                  isFrontCameraOn = !isFrontCameraOn;
                });
              },
              icon: Icon(
                Icons.flip_camera_android,
                color: isFrontCameraOn ? Colors.white : Colors.black,
              ))
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Place theQR code in designated area',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'let the scan do the magic - It starts on it own!',
                  style: TextStyle(
                      color: Colors.black54,
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
                  style: TextStyle(color: Colors.black),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
