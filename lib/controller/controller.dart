import 'package:flutter/cupertino.dart';

final class BarcodeController {
  const BarcodeController({
    required TextEditingController textEditingController,
    required FocusNode focusNode,
    required bool isCameraEnabled,
    required this.onFieldSubmitted,
    required GlobalKey<FormState> formKey,
  })  : _textEditingController = textEditingController,
        _focusNode = focusNode,
        _isCameraEnabled = isCameraEnabled,
        _formKey = formKey;

  final TextEditingController _textEditingController;
  final FocusNode _focusNode;
  final bool _isCameraEnabled;
  final void Function(String barcode, BarcodeController controller)
      onFieldSubmitted;
  final GlobalKey<FormState> _formKey;
  TextEditingController get textEditingController => _textEditingController;

  void clear() {
    _textEditingController.clear();
    if (!_isCameraEnabled) {
      _focus();
    }
  }

  bool validate() => _formKey.currentState?.validate() ?? false;

  void _focus() => _focusNode.requestFocus();

  void dispose() {
    _focusNode.dispose();
    _textEditingController.dispose();
  }

  String get getBarcode => _textEditingController.text;
  set setBarcode(String str) => _textEditingController.text = str.trim();
}
