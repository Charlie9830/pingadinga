import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:pingadinga/about_app_dialog.dart';
import 'package:pingadinga/add_device_button.dart';
import 'package:pingadinga/closing_dialog.dart';
import 'package:pingadinga/create_mock_devices.dart';
import 'package:pingadinga/device_view_model.dart';
import 'package:pingadinga/generic_error_snackbar.dart';
import 'package:pingadinga/generic_info_snackbar.dart';
import 'package:pingadinga/get_uid.dart';
import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/live_device_stats.dart';
import 'package:pingadinga/models/device_model.dart';
import 'package:pingadinga/models/project_file_model.dart';
import 'package:pingadinga/network_item.dart';
import 'package:pingadinga/network_state_chip.dart';
import 'package:pingadinga/no_devices_fallback.dart';
import 'package:pingadinga/show_alert_dialog.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as p;
import 'package:package_info_plus/package_info_plus.dart';

const String _kFileExtension = '.pingadinga';

final XTypeGroup _fileGroup = XTypeGroup(
  label: 'Pingadinga file',
  extensions: [_kFileExtension],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

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

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  Map<String, DeviceModel> _devices = {};
  Map<String, StreamSubscription<DeviceViewModel>> _streamSubcriptions = {};
  Map<String, LiveDeviceStats> _stats = {};
  final AudioPlayer _dinger = AudioPlayer();
  String _filePath = '';
  PackageInfo? _packageInfo;

  @override
  void initState() {
    _setupStreams();

    windowManager.addListener(this);
    _initWindowManager();

    _fetchPackageInfo();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceList = _devices.values.toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Pinga Dinga",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontFamily: 'ZenDots'),
        ),
        elevation: 10,
        actions: [
          ElevatedButton.icon(
            label: Text('Save'),
            icon: Icon(Icons.save),
            onPressed: _handleSaveButtonPressed,
          ),

          const SizedBox(width: 8),

          ElevatedButton.icon(
            label: Text('Save as'),
            icon: Icon(Icons.save_as),
            onPressed: _handleSaveAsButtonPressed,
          ),

          VerticalDivider(indent: 8, endIndent: 8, width: 24),

          ElevatedButton.icon(
            label: Text('Open'),
            icon: Icon(Icons.file_open),
            onPressed: _handleOpenButtonPressed,
          ),

          const SizedBox(width: 8),

          GestureDetector(onTap: _ding, child: Image.asset('assets/dinga.png')),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Tooltip(
                  message: 'Reset all connection statistics',
                  child: IconButton(
                    icon: Icon(Icons.restore),
                    onPressed: _handleResetAllStats,
                  ),
                ),

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

                Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 12,
                  children: [
                    if (_filePath.isNotEmpty)
                      Text(
                        p.basenameWithoutExtension(_filePath),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),

                    Tooltip(
                      message: 'Show application information',
                      child: IconButton(
                        onPressed: _handleAboutButtonPressed,
                        icon: Icon(Icons.code),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          deviceList.isEmpty
              ? NoDevicesFallback(
                onAddDevicesButtonPressed: _handleAddDeviceButtonPressed,
                onOpenFileButtonPressed: _handleOpenButtonPressed,
              )
              : ReorderableListView.builder(
                footer: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AddDeviceButton(onPressed: _handleAddDeviceButtonPressed),
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
                    connectionState:
                        stats?.connectionState ?? ConnectionState.unseen,
                    lastHiccup: stats?.latestHiccup,
                    onDelete: () => _handleRemoveDevice(device),
                    isPaused:
                        _streamSubcriptions.keys.contains(device.uid) == false,
                    onPauseStream: () => _handleDeviceStreamPause(device),
                    onStartStream: () => _handleDeviceStreamStart(device),
                    onChangeDeviceName:
                        (value) => _handleChangeDeviceName(device, value),
                    onChangeIpAddress:
                        (value) => _handleChangeIpAddress(device, value),
                    onResetLiveStatistics: () => _handleResetStats(device),
                  );
                },
              ),
    );
  }

  void _handleAboutButtonPressed() {
    if (_packageInfo != null) {
      showDialog(
        context: context,
        builder: (context) => AboutAppDialog(packageInfo: _packageInfo!),
      );
    }
  }

  void _fetchPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      _packageInfo = info;
    });
  }

  void _handleSaveButtonPressed() {
    _saveFile(saveAs: _filePath.isEmpty);
  }

  void _handleSaveAsButtonPressed() {
    _saveFile(saveAs: true);
  }

  void _handleOpenButtonPressed() async {
    _openFile();
  }

  void _openFile() async {
    if (_devices.isNotEmpty) {
      // We have unsaved changes. Ask the user what they want to do.
      final dialogResult = await showAlertDialog(
        context: context,
        title: 'Save Changes',
        message: 'If you continue, any unsaved changes will be lost',
        affirmativeActionLabel: 'Continue',
        negativeActionLabel: 'Go back',
      );

      if (dialogResult == false) {
        return;
      }
    }

    final targetFile = await openFile(
      acceptedTypeGroups: [_fileGroup],
      confirmButtonText: 'Open',
      initialDirectory: _filePath.isEmpty ? null : p.dirname(_filePath),
    );

    if (targetFile == null || targetFile.path.isEmpty) {
      return;
    }

    try {
      final fileContents = await File(targetFile.path).readAsString();

      final projectFileContents = ProjectFileModel.fromJson(fileContents);

      // Cancel existing Stream.
      await _cancelAllSubscriptions();

      setState(() {
        _stats = {};
        _devices = Map<String, DeviceModel>.fromEntries(
          projectFileContents.devices.map(
            (device) => MapEntry(device.uid, device),
          ),
        );
        _filePath = targetFile.path;
      });

      // Success, inform the user.
      if (_scaffoldKey.currentContext != null &&
          _scaffoldKey.currentContext!.mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          genericInfoSnackbar(
            context: _scaffoldKey.currentContext!,
            message: '${p.basename(targetFile.path)} loaded.',
          ),
        );
      }
    } catch (e) {
      if (_scaffoldKey.currentContext != null &&
          _scaffoldKey.currentContext!.mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          genericErrorSnackbar(
            context: _scaffoldKey.currentContext!,
            message: 'An error occurred: $e',
          ),
        );
      }

      rethrow;
    }
  }

  void _saveFile({required bool saveAs}) async {
    final saveLocation =
        saveAs
            ? await getSaveLocation(
              acceptedTypeGroups: [_fileGroup],
              confirmButtonText: 'Save',
              suggestedName: 'Config$_kFileExtension',
              initialDirectory: _filePath.isEmpty ? null : p.dirname(_filePath),
            )
            : FileSaveLocation(_filePath);

    if (saveLocation == null) {
      return;
    }

    final targetPath = saveLocation.path;

    // If we are Saving As, guard against accidental overwriting of an existing file.
    if (await File(targetPath).exists() && saveAs && mounted) {
      final dialogResult = await showAlertDialog(
        context: context,
        title: 'Overwrite File',
        message: 'Are you sure you want to overwrite ${p.basename(targetPath)}',
      );

      if (dialogResult == false) {
        return;
      }
    }

    try {
      // Write the project contents to File.
      final writeResult = await File(targetPath).writeAsString(
        ProjectFileModel(devices: _devices.values.toList()).toJson(),
      );

      // Success, inform the user.
      if (_scaffoldKey.currentContext != null &&
          _scaffoldKey.currentContext!.mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          genericInfoSnackbar(
            context: _scaffoldKey.currentContext!,
            message: 'File saved',
          ),
        );
      }

      setState(() {
        _filePath = writeResult.path;
      });
    } catch (e) {
      // Something has gone wrong. Inform the user.
      if (_scaffoldKey.currentContext != null &&
          _scaffoldKey.currentContext!.mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          genericErrorSnackbar(
            context: _scaffoldKey.currentContext!,
            message: 'An error occurred: $e',
          ),
        );
      }

      rethrow;
    }
  }

  void _handleResetAllStats() {
    setState(() {
      _stats = {};
    });
  }

  void _handleResetStats(DeviceModel device) {
    setState(() {
      _stats = Map<String, LiveDeviceStats>.from(_stats)
        ..update(device.uid, (existing) => LiveDeviceStats.none());
    });
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

  void _initWindowManager() async {
    await windowManager.setPreventClose(true);
  }

  @override
  void onWindowClose() async {
    final dialogResult = await showAlertDialog(
      context: context,
      title: 'Quit Pinga Dinga?',
      message:
          'Any unsaved changes will be lost, are you sure you want to quit?',
      affirmativeActionLabel: 'Quit',
      negativeActionLabel: 'Go back',
    );

    if (dialogResult == false) {
      return;
    }

    final shutdownProccesses = [
      _cancelAllSubscriptions(),
      if (mounted)
        showDialog(context: context, builder: (context) => ClosingDialog()),
    ];

    await Future.wait(shutdownProccesses);

    windowManager.destroy();
  }

  Future<void> _cancelAllSubscriptions() async {
    final cancels =
        _streamSubcriptions.values.map((sub) => sub.cancel()).toList();
    await Future.wait(cancels);

    _streamSubcriptions = {};
  }

  @override
  void dispose() {
    _cancelAllSubscriptions();

    windowManager.removeListener(this);

    super.dispose();
  }
}
