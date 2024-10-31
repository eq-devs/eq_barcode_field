import 'package:flutter/cupertino.dart';

final class BarcodeController {
  BarcodeController()
      : textEditingController = TextEditingController(),
        focusNode = FocusNode();
  TextEditingController textEditingController;
  final FocusNode focusNode;

  void clear() {
    textEditingController.clear();
  }

  void focus() {
    focusNode.requestFocus();
  }

  void dispose() {
    focusNode.dispose();
    textEditingController.dispose();
  }
}
