import 'package:flutter/material.dart';

typedef CloseDialog = void Function();
CloseDialog ShowloadingDialog({
  required BuildContext context,
  required String text,
}) {
  final Dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(
          height: 10.0,
        ),
        Text(text),
      ],
    ),
  );
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog,
  );
  return () => Navigator.of(context).pop();
}
