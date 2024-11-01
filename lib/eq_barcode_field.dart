library eq_barcode_field;

import 'dart:async';

import 'package:barcode_newland_flutter/newland_scan_result.dart';
import 'package:barcode_newland_flutter/newland_scanner.dart';
import 'package:eq_barcode_field/controller.dart';
import 'package:eq_barcode_field/page.dart';
import 'package:eq_barcode_field/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class BarcodeField extends StatefulWidget {
  const BarcodeField(
      {super.key,
      this.fillColor,
      this.borderRadius,
      this.onTap,
      this.onEditingCompleted,
      this.keyboardType,
      this.onChanged,
      this.autofocus,
      this.enabled,
      this.errorText,
      this.label,
      this.suffix,
      this.prefix,
      this.hintText,
      this.focusNode,
      required this.onFieldSubmitted,
      this.inputFormatters,
      this.style,
      this.textInputAction,
      this.maxLength,
      this.maxLines,
      this.mustValidate,
      this.prefixIcon,
      this.initStr,
      this.searchIconData,
      this.searchIconWidget,
      required this.isCameraEnabled,
      this.onClean});
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onEditingCompleted;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool? autofocus;
  final bool? enabled;
  final String? errorText;
  final String? label;
  final Widget? suffix;
  final Widget? prefix;
  final String? hintText;
  final FocusNode? focusNode;
  final Function(String barcode, BarcodeController controller) onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final int? maxLines;
  final bool? mustValidate;
  final IconData? prefixIcon;
  final String? initStr;

  final IconData? searchIconData;
  final Widget? searchIconWidget;
  final bool isCameraEnabled;

  final VoidCallback? onClean;

  @override
  State<BarcodeField> createState() => _BarcodeFieldState();
}

class _BarcodeFieldState extends State<BarcodeField>
    with AutomaticKeepAliveClientMixin {
  late final BarcodeController barcodeController;
  // late final FocusNode focusNode;
  late final StreamSubscription<NewlandScanResult> _barcodeSubscription;
  late ValueNotifier<bool> isShow;
  bool isFocused = false;
  late final GlobalKey<FormState> _formKey;

  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    barcodeController = BarcodeController(widget.isCameraEnabled);
    isShow = ValueNotifier(false);
    focusNode = widget.focusNode ?? barcodeController.focusNode;
    _formKey = GlobalKey<FormState>();
    focusNode.addListener(() {
      isFocused = focusNode.hasFocus;
    });

    _barcodeSubscription = Newlandscanner.listenForBarcodes.listen((event) {
      if (event.barcodeSuccess) {
        onBarcode(event.barcodeData);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      barcodeController.textEditingController.addListener(() {
        isShow.value = barcodeController.textEditingController.text.isNotEmpty;

        if (!isShow.value) {
          widget.onClean?.call();
        }
      });
    });
  }

  void onBarcode(String barCode) {
    if (isFocused
        //|| barcodeController.textEditingController.text.isEmpty
        ) {
      barcodeController.textEditingController.text = barCode;
      if (_formKey.currentState?.validate() ?? false) {
        // textEditingController.text = barCode;
        isShow.value = barCode.isNotEmpty;
        widget.onFieldSubmitted(barCode, barcodeController);
        focusNode.unfocus();
      }
    }
  }

  @override
  void dispose() {
    _barcodeSubscription.cancel();
    focusNode.removeListener(() {});
    barcodeController.textEditingController.dispose();
    isShow.dispose();
    super.dispose();
  }

  final UppercaseTextInputFormatter _uppercaseFormatter =
      UppercaseTextInputFormatter();

  Future<void> _openQRScanner() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const QRScanPage()));
    if (result is String && result != '-1') {
      onBarcode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: TextFormField(
              focusNode: focusNode,
              textInputAction: widget.textInputAction,
              inputFormatters: [_uppercaseFormatter],
              onTap: widget.isCameraEnabled ? _openQRScanner : null,
              readOnly: widget.isCameraEnabled,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '';
                }
                return null;
              },
              controller: barcodeController.textEditingController,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                prefixIcon:
                    widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
                errorStyle: const TextStyle(height: -.1),
                hintText: widget.hintText?.trim(),
                hintStyle: const TextStyle(color: Colors.grey),
                labelText: widget.label,
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: small,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: small,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: small,
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: small,
                ),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: small),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: isShow,
                  builder: (context, isShow, child) => !isShow
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: barcodeController.textEditingController.clear,
                          child: const Icon(Icons.clear)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        _buildSearchButton()
      ],
    );
  }

  Widget _buildSearchButton() {
    return widget.searchIconWidget ??
        CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () =>
                onBarcode(barcodeController.textEditingController.text),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 42),
                child: Container(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: small),
                    child: Icon(widget.searchIconData ?? Icons.search))));
  }

  @override
  bool get wantKeepAlive => true;
}

BorderRadius get small => BorderRadius.circular(8);
