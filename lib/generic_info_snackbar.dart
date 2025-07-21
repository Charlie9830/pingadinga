import 'package:flutter/material.dart';

SnackBar genericInfoSnackbar({
  required BuildContext context,
  required String message,
}) {
  return SnackBar(
    backgroundColor: Colors.green.shade700,
    content: Row(
      children: [
        Icon(Icons.info),
        SizedBox(width: 8),
        Text(message, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}
