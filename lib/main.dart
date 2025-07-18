import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:pingadinga/create_mock_devices.dart';
import 'package:pingadinga/device_view_model.dart';
import 'package:pingadinga/generic_error_snackbar.dart';
import 'package:pingadinga/get_uid.dart';
import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/live_device_stats.dart';
import 'package:pingadinga/models/device_model.dart';
import 'package:pingadinga/network_item.dart';
import 'package:pingadinga/network_state_chip.dart';
import 'package:pingadinga/show_alert_dialog.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinga Dinga',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Map<String, DeviceModel> _devices;
  Map<String, StreamSubscription<DeviceViewModel>> _streamSubcriptions = {};
  Map<String, LiveDeviceStats> _stats = {};
  final AudioPlayer _dinger = AudioPlayer();

  @override
  void initState() {
    _devices = createMockDevices();

    _setupStreams();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceList = _devices.values.toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Pinga Dinga"),
        elevation: 1,
        actions: [
          Tooltip(
            message: 'Start all Monitors',
            child: IconButton(
              icon: Icon(Icons.play_circle),
              onPressed: _handlePlayAllStreams,
            ),
          ),

          Tooltip(
            message: 'Pause all Monitors',
            child: IconButton(
              icon: Icon(Icons.pause_circle),
              onPressed: _handlePauseAllStreams,
            ),
          ),

          const SizedBox(width: 16),

          GestureDetector(onTap: _ding, child: Image.asset('assets/dinga.png')),
        ],
      ),
      body: ReorderableListView.builder(
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.add_circle),
              label: Text('Add Device'),
              onPressed: _handleAddDeviceButtonPressed,
            ),
          ],
        ),
        buildDefaultDragHandles: false,
        itemCount: deviceList.length,
        onReorder: _handleReorder,
        itemBuilder: (context, index) {
          final device = deviceList[index];
          final stats = _stats[device.uid];

          return NetworkItem(
            key: Key(device.uid),
            index: index,
            device: device,
            latestPingData: stats?.lastPing,
            connectionState: stats?.connectionState ?? ConnectionState.unseen,
            lastHiccup: stats?.latestHiccup,
            onDelete: () => _handleRemoveDevice(device),
            isPaused: _streamSubcriptions.keys.contains(device.uid) == false,
            onPauseStream: () => _handleDeviceStreamPause(device),
            onStartStream: () => _handleDeviceStreamStart(device),
            onChangeDeviceName:
                (value) => _handleChangeDeviceName(device, value),
            onChangeIpAddress: (value) => _handleChangeIpAddress(device, value),
          );
        },
      ),
    );
  }

  void _ding() async {
    _dinger.play(AssetSource('ding.wav'));
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final items = _devices.values.toList();

    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    setState(() {
      _devices = Map<String, DeviceModel>.fromEntries(
        items.map((item) => MapEntry(item.uid, item)),
      );
    });
  }

  void _handleChangeDeviceName(DeviceModel device, String newValue) {
    setState(() {
      _devices = Map<String, DeviceModel>.from(_devices)..update(
        device.uid,
        (existing) => existing.copyWith(name: newValue.trim()),
      );
    });
  }

  void _handleChangeIpAddress(DeviceModel device, String ipAddress) {
    if (_streamSubcriptions.containsKey(device.uid)) {
      // Don't try and change an IP Address while a device is actively pinging.
      return;
    }

    final trimedAddress = ipAddress.trim();

    try {
      InternetAddress(trimedAddress);
    } on ArgumentError catch (_) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        genericErrorSnackbar(context: context, message: 'Invalid IP Address.'),
      );

      return;
    }

    // If we have reached here then the address is valid.
    final updatedDevice = device.copyWith(ipAddress: trimedAddress);
    setState(() {
      _devices = Map<String, DeviceModel>.from(_devices)
        ..update(device.uid, (_) => updatedDevice);
    });

    // Don't need to update or start the stream yet. That will happen when the user Unpauses the Stream.
  }

  void _handlePlayAllStreams() async {
    for (final device in _devices.values) {
      if (_streamSubcriptions.containsKey(device.uid) == false) {
        _streamSubcriptions[device.uid] = _startAndSubscribeToPing(device);
      }
    }
  }

  void _handlePauseAllStreams() async {
    final stopRequests = _streamSubcriptions.values.map((sub) => sub.cancel());

    await Future.wait(stopRequests);

    _streamSubcriptions = {};

    setState(() {});
  }

  void _handleDeviceStreamPause(DeviceModel device) async {
    final subscription = _streamSubcriptions.remove(device.uid);

    await subscription?.cancel();

    setState(() {});
  }

  void _handleDeviceStreamStart(DeviceModel device) async {
    if (_streamSubcriptions.containsKey(device.uid)) {
      final sub = _streamSubcriptions.remove(device.uid);
      await sub!.cancel();
    }

    _streamSubcriptions[device.uid] = _startAndSubscribeToPing(device);
  }

  void _handleRemoveDevice(DeviceModel device) async {
    final result = await showAlertDialog(
      context: context,
      title: 'Remove device',
      message: 'Are you sure you want to remove ${device.name}?',
      affirmativeActionLabel: 'Remove',
      negativeActionLabel: 'Cancel',
    );

    if (result == true) {
      await _streamSubcriptions[device.uid]?.cancel();
      _streamSubcriptions.remove(device.uid);

      setState(() {
        _stats = Map<String, LiveDeviceStats>.from(_stats)..remove(device.uid);
        _devices = Map<String, DeviceModel>.from(_devices)..remove(device.uid);
      });
    }
  }

  void _handleAddDeviceButtonPressed() {
    final newDevice = DeviceModel(uid: getUid(), ipAddress: '', name: '');

    setState(() {
      _devices = Map<String, DeviceModel>.from(_devices)
        ..addAll({newDevice.uid: newDevice});
    });
  }

  @override
  void dispose() {
    for (final sub in _streamSubcriptions.values) {
      sub.cancel();
    }

    super.dispose();
  }

  void _setupStreams() {
    _streamSubcriptions =
        Map<String, StreamSubscription<DeviceViewModel>>.fromEntries(
          _devices.values.map((device) {
            final deviceId = device.uid;
            return MapEntry(deviceId, _startAndSubscribeToPing(device));
          }),
        );
  }

  StreamSubscription<DeviceViewModel> _startAndSubscribeToPing(
    DeviceModel device,
  ) {
    return Ping(device.ipAddress).stream
        .map((ping) => DeviceViewModel(device: device, ping: ping))
        .listen(_handleStreamData);
  }

  void _handleStreamData(DeviceViewModel vm) {
    setState(() {
      _stats = Map<String, LiveDeviceStats>.from(_stats)..update(
        vm.device.uid,
        (existing) => _resolveConnectionStats(existing, vm.ping),
        ifAbsent:
            () => _resolveConnectionStats(LiveDeviceStats.none(), vm.ping),
      );
    });
  }

  LiveDeviceStats _resolveConnectionStats(
    LiveDeviceStats existing,
    PingData ping,
  ) {
    final lastConnectionState = existing.connectionState;

    if (ping.error == null && ping.response != null) {
      // Good Ping.
      return switch (lastConnectionState) {
        // First time seeing the device. Welcome to the party.
        ConnectionState.unseen => LiveDeviceStats(
          connectionState: ConnectionState.connected,
          lastPing: ping,
          latestHiccup: null,
        ),

        // Device was seen to discconect, but has recconected.
        ConnectionState.disconnected => existing.copyWith(
          connectionState: ConnectionState.reconnected,
          lastPing: ping,
          latestHiccup: existing.latestHiccup?.copyWith(
            endTimestamp: DateTime.now(),
          ),
        ),

        // Device is just doin it's thang.
        ConnectionState.reconnected ||
        ConnectionState.connected => existing.copyWith(lastPing: ping),
      };
    } else {
      // Bad Ping.
      return switch (lastConnectionState) {
        // Never seen the device before. So don't push any big red buttons yet.
        ConnectionState.unseen => LiveDeviceStats(
          connectionState: ConnectionState.unseen,
          lastPing: ping,
          latestHiccup: null,
        ),
        // Device was previously connected. Flag it as discconected and record the timestamp.
        ConnectionState.connected ||
        ConnectionState.reconnected => LiveDeviceStats(
          connectionState: ConnectionState.disconnected,
          lastPing: ping,
          latestHiccup: Hiccup(
            startTimestamp: DateTime.now(),
            missedPings: 1,
            endTimestamp: null,
          ),
        ),
        // Device was previously already discconected. So continue as normal with its discconected state.
        ConnectionState.disconnected => LiveDeviceStats(
          connectionState: ConnectionState.disconnected,
          lastPing: ping,
          latestHiccup: existing.latestHiccup?.withMissedPing(),
        ),
      };
    }
  }
}
