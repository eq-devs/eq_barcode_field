import 'dart:async';
import 'dart:io';

import 'package:barcode_newland_flutter/newland_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

@immutable
class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        controller?.pauseCamera();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        controller?.resumeCamera();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('扫描')),
      body: Center(
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.grey,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300),
        ),
      ),
    );
  }

  bool scaned = false;

  void _onQRViewCreated(QRViewController controller) {
    final navigatorState = Navigator.of(context);
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!scaned) {
        navigatorState.pop(scanData.code);

        scaned = true;
      }
    });
  }
}

typedef BarcodeScannedVoidCallBack = void Function(String barcode);

@immutable
class BarcodeInputListener extends StatefulWidget {
  const BarcodeInputListener({
    super.key,
    required this.child,
    required this.onBarcodeScanned,
    this.bufferDuration =
        const Duration(milliseconds: 100), // Adjust as necessary
    this.useKeyDownEvent = false,
  });

  final Widget child;
  final BarcodeScannedVoidCallBack onBarcodeScanned;
  final Duration bufferDuration;
  final bool useKeyDownEvent;

  @override
  State<BarcodeInputListener> createState() => _BarcodeInputListenerState();
}

class _BarcodeInputListenerState extends State<BarcodeInputListener> {
  final List<String> _bufferedChars = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Newlandscanner.listenForBarcodes.listen((e) {
        widget.onBarcodeScanned(e.barcodeData);
      });
    });

    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      HardwareKeyboard.instance.addHandler(_onKeyEvent);
    }
  }

  @override
  void dispose() {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  bool _onKeyEvent(KeyEvent event) {
    if ((!widget.useKeyDownEvent && event is KeyUpEvent) ||
        (widget.useKeyDownEvent && event is KeyDownEvent)) {
      String? char = _getCharacterFromEvent(event);
      if (char != null) {
        _handleKeyEvent(char);
      }
    }
    return true;
  }

  String? _getCharacterFromEvent(KeyEvent event) {
    final String? char = event.character;
    if (char != null && char.isNotEmpty) {
      return char;
    }
    return null;
  }

  void _handleKeyEvent(String char) {
    // Add character to buffer
    _bufferedChars.add(char);

    // Cancel the existing debounce timer if a new character is added
    _debounceTimer?.cancel();

    // Start a new debounce timer
    _debounceTimer = Timer(widget.bufferDuration, () {
      // When debounce timer finishes, treat it as the end of the barcode scan
      final barcode = _bufferedChars.join();
      widget.onBarcodeScanned(barcode); // Call once after scan is complete
      _bufferedChars.clear(); // Clear buffer for the next scan
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return widget.child;
    } else {
      final focusNode = FocusNode();
      focusNode.requestFocus();
      return KeyboardListener(
        autofocus: true,
        includeSemantics: true,
        focusNode: focusNode,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            String? char = event.character;
            if (char != null) {
              _handleKeyEvent(char);
            }
          }
        },
        child: widget.child,
      );
    }
  }
}
