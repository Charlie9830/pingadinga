import 'package:flutter/material.dart';

class ClosingDialog extends StatefulWidget {
  const ClosingDialog({super.key});

  @override
  State<ClosingDialog> createState() => _ClosingDialogState();
}

class _ClosingDialogState extends State<ClosingDialog> {
  @override
  void initState() {
    _startMininmumTimer();
    super.initState();
  }

  void _startMininmumTimer() async {
    await Future.delayed(Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(),
            Text(
              'Shutting down',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
