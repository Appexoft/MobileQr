import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QRScannerOverlay extends StatelessWidget {
  const QRScannerOverlay({Key? key, required this.overlayColour}) : super(key: key);

  final Color overlayColour;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(overlayColour, BlendMode.srcOut), // This one will create the magic
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.red, backgroundBlendMode: BlendMode.dstOut), // This one will handle background + difference out
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 0.8.sw,
                width: 0.8.sw,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      Align(
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: BorderPainter(),
          child: SizedBox(
            width: 0.8.sw + 20,
            height: 0.8.sw + 20,
          ),
        ),
      ),
    ]);
  }
}

// Creates the white borders
class BorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const width = 5.0;
    const radius = 10.0;
    //const tRadius = 2 * radius;
    final rect = Rect.fromLTWH(
      width,
      width,
      size.width - 2 * width,
      size.height - 2 * width,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    const clippingRect0 = Rect.fromLTWH(
      0,
      0,
      40,
      40,
    );
    final clippingRect1 = Rect.fromLTWH(
      size.width - 40,
      0,
      40,
      40,
    );
    final clippingRect2 = Rect.fromLTWH(
      0,
      size.height - 40,
      40,
      40,
    );
    final clippingRect3 = Rect.fromLTWH(
      size.width - 40,
      size.height - 40,
      40,
      40,
    );

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
