import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

@immutable
class UppercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Convert the entered text to uppercase
    return newValue.copyWith(
        text: newValue.text.toUpperCase(), selection: newValue.selection);
  }
}


