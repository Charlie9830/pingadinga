import 'package:flutter/material.dart';

class AddDividerButton extends StatelessWidget {
  final void Function() onPressed;
  const AddDividerButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(Icons.add),
      label: Text('Add Divider'),
      onPressed: onPressed,
    );
  }
}
