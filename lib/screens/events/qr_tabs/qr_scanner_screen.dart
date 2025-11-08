import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotseeker_app/screens/events/qr_tabs/ticket_onboarding_bottom_sheet.dart';
import 'dart:math' as math;
 
// TODO: preserve any intentional TODOs
class QRScannerOverlay extends CustomPainter {
  final double scanSize;
  final double scanTop;
  final double screenWidth;

  QRScannerOverlay({
    required this.scanSize,
    required this.scanTop,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final left = (screenWidth - scanSize) / 2;
    final scanRect = Rect.fromLTWH(left, scanTop, scanSize, scanSize);

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, scanTop), paint);
    canvas.drawRect(Rect.fromLTWH(0, scanTop, left, scanSize), paint);
    canvas.drawRect(Rect.fromLTWH(left + scanSize, scanTop, size.width - (left + scanSize), scanSize), paint);
    canvas.drawRect(Rect.fromLTWH(0, scanTop + scanSize, size.width, size.height - (scanTop + scanSize)), paint);
    
    final innerFill = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;
    canvas.drawRect(scanRect, innerFill);

    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final cornerLen = math.min(scanSize * 0.48, 90.0);

    final leftX = scanRect.left - 5;
    final topY = scanRect.top - 5;
    final rightX = scanRect.right + 5;
    final bottomY = scanRect.bottom + 5;

    canvas.drawLine(Offset(leftX, topY), Offset(leftX + cornerLen, topY), cornerPaint);
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, topY + cornerLen), cornerPaint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX - cornerLen, topY), cornerPaint);
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, topY + cornerLen), cornerPaint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(leftX + cornerLen, bottomY), cornerPaint);
    canvas.drawLine(Offset(leftX, bottomY), Offset(leftX, bottomY - cornerLen), cornerPaint);
    canvas.drawLine(Offset(rightX, bottomY), Offset(rightX - cornerLen, bottomY), cornerPaint);
    canvas.drawLine(Offset(rightX, bottomY), Offset(rightX, bottomY - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant QRScannerOverlay oldDelegate) {
    return oldDelegate.scanSize != scanSize || 
           oldDelegate.scanTop != scanTop ||
           oldDelegate.screenWidth != screenWidth;
  }
}

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanQRSelected = true;
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  bool hasPermission = false;
  bool isCheckingPermission = true;
  // Track whether the device torch/flash is currently on
  bool isFlashOn = false;
  final TextEditingController _bookingIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _bookingIdController.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    
    setState(() {
      hasPermission = status.isGranted;
      isCheckingPermission = false;
      if (hasPermission) {
        isScanning = true;
      }
    });

    if (!hasPermission && status.isDenied) {
      _requestCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    
    setState(() {
      hasPermission = status.isGranted;
      if (hasPermission) {
        isScanning = true;
        _bookingIdController.clear();
      }
    });

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Camera Permission Required', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This app needs camera access to scan QR codes. Please enable camera permission in your device settings.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        final topPadding = math.max(12.0, screenHeight * 0.02);
        final horizontalPadding = math.max(12.0, screenWidth * 0.04);
        const networkRowHeight = 30.0;
        final spacingAfterNetwork = math.max(12.0, screenHeight * 0.02);
        const toggleButtonHeight = 48.0;
        final spacingAfterToggle = math.max(16.0, screenHeight * 0.03);
        final flashButtonHeight = math.min(64.0, screenHeight * 0.09).clamp(56.0, 64.0);
        final spacingAfterScanBox = math.max(8.0, screenHeight * 0.015);
        final scanBoxTop = topPadding + networkRowHeight + spacingAfterNetwork + 
                          toggleButtonHeight + spacingAfterToggle;
        final availableContentHeight = screenHeight - scanBoxTop - topPadding;
        final availableWidth = screenWidth - (horizontalPadding * 2);
        final maxScanSize = availableContentHeight - flashButtonHeight - spacingAfterScanBox;
        final scanSize = math.min(
          math.min(availableWidth, maxScanSize) * 0.85,
          350.0
        ).clamp(180.0, 350.0);

        return Stack(
          children: [
            
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Image.asset(
                    'assets/qr_scanner.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),

            if (isScanQRSelected && isScanning && hasPermission)
              Positioned.fill(
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        setState(() {
                          isScanning = false;
                        });
                        _showScanResult(barcode.rawValue!);
                      }
                    }
                  },
                ),
              ),

            if (isScanQRSelected)
              Positioned.fill(
                child: CustomPaint(
                  painter: QRScannerOverlay(
                    scanSize: scanSize,
                    scanTop: scanBoxTop,
                    screenWidth: screenWidth,
                  ),
                ),
              ),

            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: topPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      SizedBox(
                        height: networkRowHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.signal_cellular_alt,
                                  size: 18,
                                  color: Color(0xFF00A54F),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Network',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00A54F),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Color(0xFF00A54F),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacingAfterNetwork),

                      
                      SizedBox(
                        height: toggleButtonHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  // Switch to Scan QR mode. Ensure camera permission and start scanning.
                                  setState(() {
                                    isScanQRSelected = true;
                                  });

                                  if (!hasPermission) {
                                    _requestCameraPermission();
                                  } else {
                                    // If flash was left on previously, turn it off when entering fresh scan mode
                                    if (isFlashOn) {
                                      try {
                                        await cameraController.toggleTorch();
                                      } catch (_) {}
                                      setState(() {
                                        isFlashOn = false;
                                      });
                                    }

                                    setState(() {
                                      isScanning = true;
                                      _bookingIdController.clear();
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isScanQRSelected 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Scan QR',
                                      style: TextStyle(
                                        color: isScanQRSelected 
                                            ? Colors.black 
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: isScanQRSelected 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  // When switching to typing mode, stop scanning and ensure torch is off
                                  if (isFlashOn) {
                                    try {
                                      await cameraController.toggleTorch();
                                    } catch (_) {}
                                  }

                                  setState(() {
                                    isScanQRSelected = false;
                                    isScanning = false;
                                    isFlashOn = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isScanQRSelected 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Type Booking ID',
                                      style: TextStyle(
                                        color: !isScanQRSelected 
                                            ? Colors.black 
                                            : Colors.white,
                                        fontSize: 16,
                                        fontWeight: !isScanQRSelected 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: spacingAfterToggle),

                      
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: scanSize,
                              maxHeight: availableContentHeight,
                            ),
                            child: isScanQRSelected
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                    
                                      SizedBox(
                                        width: scanSize,
                                        height: scanSize,
                                      ),
                                        SizedBox(height: spacingAfterScanBox),
                                      
                                      GestureDetector(
                                        onTap: () async {
                                          // If we don't have permission, request it
                                          if (!hasPermission) {
                                            _requestCameraPermission();
                                            return;
                                          }

                                          // If camera isn't active, start scanning first
                                          if (!isScanning) {
                                            setState(() {
                                              isScanning = true;
                                              _bookingIdController.clear();
                                            });
                                            return;
                                          }

                                          // Toggle the device torch
                                          try {
                                            await cameraController.toggleTorch();
                                            setState(() {
                                              isFlashOn = !isFlashOn;
                                            });
                                          } catch (e) {
                                            // Best-effort feedback to user
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Flash not available')),
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: flashButtonHeight,
                                          height: flashButtonHeight,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              // Update icon and color based on state
                                              isFlashOn ? Icons.flash_on : Icons.flash_off,
                                              size: flashButtonHeight * 0.38,
                                              color: isFlashOn ? Colors.black: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        
                                        Container(
                                          width: scanSize,
                                          height: scanSize,
                                          padding: EdgeInsets.all(math.max(20.0, scanSize * 0.08)),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.white, width: 1),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Booking ID',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: Center(
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: TextField(
                                                      controller: _bookingIdController,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: 'Type Here',
                                                        hintStyle: TextStyle(
                                                          color: Colors.white.withOpacity(0.4),
                                                          fontSize: 18,
                                                        ),
                                                        border: InputBorder.none,
                                                        isDense: true,
                                                        contentPadding: EdgeInsets.zero,
                                                      ),
                                                      keyboardType: TextInputType.text,
                                                      textInputAction: TextInputAction.done,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                          SizedBox(height: spacingAfterScanBox),
                                          GestureDetector(
                                          onTap: () {
                                            if (_bookingIdController.text.isNotEmpty) {
                                              _verifyBookingId(_bookingIdController.text);
                                            } else {
                                              
                                              showDialog<void>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  backgroundColor: Colors.black,
                                                  title: const Text(
                                                    'Missing Booking ID',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                  content: const Text(
                                                    'Please enter a booking ID before verifying.',
                                                    style: TextStyle(color: Colors.white70),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                                                      child: const Text('OK'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: math.max(50.0, flashButtonHeight),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE50914),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: const Color(0xFFE50914),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'Verify',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.32,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showScanResult(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('QR Code Scanned', style: TextStyle(color: Colors.white)),
        content: Text('Result: $result', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanning = true;
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE50914)),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _verifyBookingId(String bookingId) {
    showTicketOnboardingSheet(context, mockTicketOnboardingData()).then((result) {
      if (result != null) {
        print('Action: ${result['action']}, Count: ${result['count'] ?? 'all'}');
        if (result['action'] == 'selected') {
          print('Onboarding ${result['count']} selected tickets');
        } else if (result['action'] == 'all') {
          print('Onboarding all tickets');
        }
      }
    });
  }
}