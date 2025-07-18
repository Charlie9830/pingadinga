import 'package:flutter/material.dart';

class ResponseTime extends StatelessWidget {
  final int? milliseconds;
  const ResponseTime({super.key, required this.milliseconds});

  @override
  Widget build(BuildContext context) {
    if (milliseconds == null) {
      return Text(
        'Waiting',
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.orange),
      );
    }

    return Text(
      '${milliseconds}ms',
      style: Theme.of(
        context,
      ).textTheme.bodySmall!.copyWith(color: _getColor(milliseconds!)),
    );
  }

  Color _getColor(int milliseconds) {
    return switch (milliseconds) {
      int a when a <= 5 => Colors.green,
      int a when a <= 20 => Colors.orange,
      _ => Colors.red,
    };
  }
}
