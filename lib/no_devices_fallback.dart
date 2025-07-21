import 'package:flutter/material.dart';
import 'package:pingadinga/add_device_button.dart';

class NoDevicesFallback extends StatelessWidget {
  final void Function() onAddDevicesButtonPressed;
  final void Function() onOpenFileButtonPressed;
  const NoDevicesFallback({
    super.key,
    required this.onAddDevicesButtonPressed,
    required this.onOpenFileButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          Text(
            'To get started, Add devices to monitor, or open an existing configuration.',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              AddDeviceButton(onPressed: onAddDevicesButtonPressed),
              TextButton.icon(
                icon: Icon(Icons.file_open),
                label: Text('Open'),
                onPressed: onOpenFileButtonPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
