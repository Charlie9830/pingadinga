import 'package:flutter/material.dart';

enum ConnectionState { unseen, connected, disconnected, reconnected }

class ConnectionStateChip extends StatelessWidget {
  final ConnectionState connectionState;
  const ConnectionStateChip({super.key, required this.connectionState});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _getMessage(connectionState),
      child: CircleAvatar(
        radius: 8,
        backgroundColor: switch (connectionState) {
          ConnectionState.unseen => Colors.grey,
          ConnectionState.connected => Colors.green,
          ConnectionState.disconnected => Colors.red,
          ConnectionState.reconnected => Colors.orange,
        },
      ),
    );
  }

  String _getMessage(ConnectionState state) {
    return switch (state) {
      ConnectionState.unseen =>
        'Device has not yet been detected during this session.',

      ConnectionState.connected => 'Device is connected and responding.',

      ConnectionState.disconnected => 'Device is no longer responding',

      ConnectionState.reconnected =>
        'Device was discconected, but has since reconnected',
    };
  }
}
