import 'package:flutter/material.dart';

Future<bool> showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String affirmativeActionLabel = "Okay",
  String? negativeActionLabel,
}) async {
  return await showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (negativeActionLabel != null)
              TextButton(
                child: Text(negativeActionLabel),
                onPressed: () => Navigator.of(context).pop(false),
              ),

            FilledButton(
              child: Text(affirmativeActionLabel),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
  );
}
