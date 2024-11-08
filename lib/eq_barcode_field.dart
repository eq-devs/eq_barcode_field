library eq_barcode_field;

import 'dart:async';

import 'package:barcode_newland_flutter/newland_scan_result.dart';
import 'package:barcode_newland_flutter/newland_scanner.dart';
import 'package:eq_barcode_field/controller.dart';
import 'package:eq_barcode_field/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'page.dart';

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
      this.onClean,
      this.loopScan = false});

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
  final void Function(String barcode, BarcodeController controller)
      onFieldSubmitted;
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
  final bool loopScan;

  @override
  State<BarcodeField> createState() => _BarcodeFieldState();
}

class _BarcodeFieldState extends State<BarcodeField>
    with AutomaticKeepAliveClientMixin {
  final UppercaseTextInputFormatter _uppercaseFormatter =
      UppercaseTextInputFormatter();
  late final BarcodeController barcodeController;
  late final StreamSubscription<NewlandScanResult> _barcodeSubscription;
  late final ValueNotifier<bool> isShow;
  late final GlobalKey<FormState> _formKey;
  late final FocusNode focusNode;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    focusNode = widget.focusNode ?? FocusNode();
    textEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    barcodeController = BarcodeController(
        textEditingController: textEditingController,
        focusNode: focusNode,
        isCameraEnabled: widget.isCameraEnabled,
        onFieldSubmitted: widget.onFieldSubmitted);
    isShow = ValueNotifier(false);
    _barcodeSubscription = Newlandscanner.listenForBarcodes.listen((event) {
      if (event.barcodeSuccess &&
          (widget.loopScan || barcodeController.getBarcode.isEmpty)) {
        barcodeController.setBarcode = event.barcodeData;
        onBarcode();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      barcodeController.textEditingController.addListener(() {
        isShow.value = barcodeController.getBarcode.isNotEmpty;
        if (!isShow.value) {
          widget.onClean?.call();
        }
      });
    });
  }

  void onBarcode() {
    if (_formKey.currentState?.validate() ?? false) {
      isShow.value = barcodeController.getBarcode.isNotEmpty;
      widget.onFieldSubmitted(barcodeController.getBarcode, barcodeController);
      focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _barcodeSubscription.cancel();
    isShow.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const QRScanPage()));
    if (result is String && result != '-1') {
      barcodeController.setBarcode = result;
      onBarcode();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(children: [
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
              if (value == null || value.isEmpty) return '';
              return null;
            },
            controller: barcodeController.textEditingController,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onFieldSubmitted: (value) {
              onBarcode();
            },
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
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(8)),
              suffixIcon: ValueListenableBuilder(
                valueListenable: isShow,
                builder: (context, isShow, child) => !isShow
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        onTap: barcodeController.textEditingController.clear,
                        child: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 2),
      _buildSearchButton()
    ]);
  }

  Widget _buildSearchButton() =>
      widget.searchIconWidget ??
      CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onBarcode,
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 42),
              child: Container(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(widget.searchIconData ?? Icons.search))));

  @override
  bool get wantKeepAlive => true;
}
