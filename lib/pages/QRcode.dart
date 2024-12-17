import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:smmic/components/bottomnavbar/bottom_nav_bar.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/pages/devices.dart';
import 'package:smmic/pages/devices_subpages/sensor_node_subpage.dart';
import 'package:smmic/pages/qrResult.dart';
import 'package:smmic/providers/devices_provider.dart';
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

                          void showBarcodeData() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return QRResult(code: code, closeScreen: closeScreen);
                                })
                            );
                          }

                          SensorNode? seCheck = context.read<DevicesProvider>()
                              .sensorNodeMap[code];
                          if (seCheck != null) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Flex(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    direction: Axis.vertical,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(25)),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
                                          child: Container(
                                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              borderRadius: const BorderRadius.all(Radius.circular(15)),
                                            ),
                                            child: Column(
                                              children: [
                                                RichText(
                                                  textAlign: TextAlign.center,
                                                  text: TextSpan(
                                                      text: 'Go to ',
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 24,
                                                      ),
                                                      children: [
                                                        TextSpan(
                                                          text: seCheck.deviceName,
                                                          style: const TextStyle(
                                                              fontFamily: 'Inter',
                                                              fontSize: 24,
                                                              fontWeight: FontWeight.bold
                                                          ),
                                                        ),
                                                        const TextSpan(
                                                          text: ' device page?',
                                                          style: TextStyle(
                                                              fontFamily: 'Inter',
                                                              fontSize: 24
                                                          ),
                                                        ),
                                                      ]
                                                  ),
                                                ),
                                                SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    TextButton(
                                                      style: ButtonStyle(
                                                          backgroundColor: WidgetStatePropertyAll(
                                                              Colors.green
                                                          )
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(builder: (context) {
                                                              return const BottomNavBar(initialIndexPage: 1);
                                                            })
                                                        );
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) {
                                                              return SensorNodePage(
                                                                  deviceID: seCheck.deviceID,
                                                                  deviceName: seCheck.deviceName,
                                                                  deviceInfo: seCheck
                                                              );
                                                            })
                                                        );
                                                      },
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        width: 90,
                                                        height: 25,
                                                        child: const Text(
                                                          'Continue',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                              fontFamily: 'Inter'
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15),
                                                    TextButton(
                                                      style: ButtonStyle(
                                                          backgroundColor: WidgetStatePropertyAll(
                                                              Colors.grey
                                                          )
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Container(
                                                        alignment: Alignment.center,
                                                        width: 90,
                                                        height: 25,
                                                        child: const Text(
                                                          'Not Now',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                              fontFamily: 'Inter'
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }
                            );
                          } else {
                            showBarcodeData();
                          }
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
