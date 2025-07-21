import 'package:flutter/material.dart';

class AddDeviceButton extends StatelessWidget {
  final void Function() onPressed;
  const AddDeviceButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(Icons.add_circle),
      label: Text('Add Device'),
      onPressed: onPressed,
    );
  }
}
