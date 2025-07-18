// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dart_ping/dart_ping.dart';

import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/network_state_chip.dart';

class LiveDeviceStats {
  ConnectionState connectionState;
  Hiccup? latestHiccup;
  PingData lastPing;

  LiveDeviceStats({
    required this.connectionState,
    required this.lastPing,
    required this.latestHiccup,
  });

  factory LiveDeviceStats.none() {
    return LiveDeviceStats(
      connectionState: ConnectionState.unseen,
      lastPing: PingData(),
      latestHiccup: null,
    );
  }

  LiveDeviceStats copyWith({
    ConnectionState? connectionState,
    Hiccup? latestHiccup,
    PingData? lastPing,
  }) {
    return LiveDeviceStats(
      connectionState: connectionState ?? this.connectionState,
      latestHiccup: latestHiccup ?? this.latestHiccup,
      lastPing: lastPing ?? this.lastPing,
    );
  }
}
