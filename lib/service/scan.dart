import 'dart:async';

import 'package:barcode_newland_flutter/newland_scan_result.dart';
import 'package:barcode_newland_flutter/newland_scanner.dart';

final class ScanService {
  ScanService._();
  static final ScanService _instance = ScanService._();
  static ScanService get I => _instance;

  late StreamSubscription<NewlandScanResult> _barcodeSubscription;
  late StreamController<NewlandScanResult> _barcodeController;
  Stream<NewlandScanResult> get barcodeStream => _barcodeController.stream;

  void init() {
    _barcodeController = StreamController<NewlandScanResult>.broadcast();
    _barcodeSubscription = Newlandscanner.listenForBarcodes.listen((e) {
      if (e.barcodeSuccess) {
        _barcodeController.add(e);
      }
    });
  }

  void dispose() {
    _barcodeSubscription.cancel();
    _barcodeController.close();
  }
}
