import 'package:flutter/material.dart';

SnackBar genericErrorSnackbar({
  required BuildContext context,
  required String message,
}) {
  return SnackBar(
    backgroundColor: Colors.red.shade700,
    content: Row(
      children: [
        Icon(Icons.error),
        SizedBox(width: 8),
        Text(message, style: Theme.of(context).textTheme.labelLarge),
      ],
    ),
  );
}
