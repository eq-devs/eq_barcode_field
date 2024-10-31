import 'package:flutter/cupertino.dart';

final class BarcodeController {
  BarcodeController(this.isCameraEnabled)
      : textEditingController = TextEditingController(),
        focusNode = FocusNode();
  TextEditingController textEditingController;
  final FocusNode focusNode;

  final bool isCameraEnabled;

  void clear() {
    textEditingController.clear();

    if (!isCameraEnabled) {
      focus();
    }
  }

  void focus() {
    focusNode.requestFocus();
  }

  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
  }
}
