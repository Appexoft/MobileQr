import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:timeaccess_qrcode/presentation/home.dart';
import 'package:timeaccess_qrcode/widgets/camera_overlay.dart';

class DetectScreen extends StatefulWidget {
  final ActionType actionType;

  const DetectScreen({super.key, required this.actionType});

  @override
  State<DetectScreen> createState() => _DetectScreenState();
}

class _DetectScreenState extends State<DetectScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    //facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.normal,
    returnImage: false,
  );
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scannerController,
              overlay: QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.3)),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  // debugPrint('Barcode found! ${barcodes[0].rawValue}');
                  if (_isDetecting) return;
                  _isDetecting = true;
                  Navigator.of(context).pop(barcodes[0].rawValue);
                }
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.black,
                child: InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: const SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      widget.actionType == ActionType.clockedId ? "Clock In" : "Clock Out",
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Scan your QR Code",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
