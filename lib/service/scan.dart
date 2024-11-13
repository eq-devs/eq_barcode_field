import 'dart:async';

import 'package:barcode_newland_flutter/newland_scan_result.dart';
import 'package:barcode_newland_flutter/newland_scanner.dart';
import 'package:eq_barcode_field/lib.dart';
import 'package:flutter/material.dart';

final class ScanService {
  ScanService._();
  static final ScanService _instance = ScanService._();
  static ScanService get I => _instance;

  late StreamSubscription<NewlandScanResult> _barcodeSubscription;
  late StreamController<NewlandScanResult> _barcodeController;
  Stream<NewlandScanResult> get barcodeStream => _barcodeController.stream;

  bool _inited = false;
  void init() {
    if (_inited) return;
    _barcodeController = StreamController<NewlandScanResult>.broadcast();
    _barcodeSubscription = Newlandscanner.listenForBarcodes.listen((e) {
      if (e.barcodeSuccess) _barcodeController.add(e);
    });
    _inited = true;
  }

  Future<NewlandScanResult?> openScanner(BuildContext context) async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const QRScanPage()));
    if (result is String && result != '-1') {
      if (_inited) {
        final res = NewlandScanResult(result, result, true);
        _barcodeController.add(res);
        return res;
      }
    }
    return null;
  }

  void dispose() {
    _barcodeSubscription.cancel();
    _barcodeController.close();
  }
}
