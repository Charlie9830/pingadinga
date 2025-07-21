import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:pingadinga/editable_text_field.dart';
import 'package:pingadinga/generic_error_snackbar.dart';
import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/hover_region.dart';
import 'package:pingadinga/latest_hiccup_timestamp.dart';
import 'package:pingadinga/models/device_model.dart';
import 'package:pingadinga/network_state_chip.dart';
import 'package:pingadinga/response_time.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NetworkItem extends StatelessWidget {
  final PingData? latestPingData;
  final DeviceModel device;
  final ConnectionState connectionState;
  final Hiccup? lastHiccup;
  final void Function() onDelete;
  final void Function() onStartStream;
  final void Function() onPauseStream;
  final void Function(String value) onChangeDeviceName;
  final void Function(String value) onChangeIpAddress;
  final void Function() onResetLiveStatistics;
  final bool isPaused;
  final int index;

  const NetworkItem({
    super.key,
    required this.latestPingData,
    required this.device,
    required this.connectionState,
    required this.lastHiccup,
    required this.onDelete,
    required this.isPaused,
    required this.onPauseStream,
    required this.onStartStream,
    required this.onChangeDeviceName,
    required this.onChangeIpAddress,
    required this.index,
    required this.onResetLiveStatistics,
  });

  @override
  Widget build(BuildContext context) {
    return HoverRegionBuilder(
      builder: (context, isHovering) {
        return Card(
          color:
              isPaused
                  ? Colors.blue.shade900
                  : connectionState == ConnectionState.disconnected
                  ? const Color.fromARGB(255, 110, 21, 21)
                  : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  child: ConnectionStateChip(connectionState: connectionState),
                ),
                SizedBox(
                  width: 200,
                  child: EditableTextField(
                    value: device.name,
                    hintText: 'Device Name...',
                    onChanged: onChangeDeviceName,
                  ),
                ),

                const SizedBox(width: 16),

                SizedBox(
                  width: 124,
                  child: Tooltip(
                    message:
                        isPaused == false
                            ? 'Pause Monitor first to change IP Address'
                            : '',
                    child: EditableTextField(
                      enabled: isPaused,
                      hintText: 'IP Address',
                      value: device.ipAddress,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: onChangeIpAddress,
                    ),
                  ),
                ),

                const SizedBox(width: 8.0),
                Tooltip(
                  message: 'Open IP address in browser',
                  child: IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () => _handleOpenInBrowser(context, device),
                  ),
                ),

                Spacer(),

                if ((connectionState == ConnectionState.disconnected ||
                        connectionState == ConnectionState.reconnected) &&
                    lastHiccup != null)
                  LatestHiccup(hiccup: lastHiccup!),

                Spacer(),

                SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isHovering
                          ? Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 24),
                              ReorderableDragStartListener(
                                index: index,
                                child: Tooltip(
                                  message: 'Drag to reorder devices',
                                  child: IconButton(
                                    icon: Icon(Icons.drag_handle),
                                    padding: EdgeInsets.all(0.0),
                                    constraints: BoxConstraints(),
                                    onPressed: () {},
                                  ),
                                ),
                              ),

                              Tooltip(
                                message: 'Reset connection statistics',
                                child: IconButton(
                                  icon: Icon(Icons.restore),
                                  padding: EdgeInsets.all(0.0),
                                  constraints: BoxConstraints(),
                                  onPressed: onResetLiveStatistics,
                                ),
                              ),

                              Tooltip(
                                message:
                                    isPaused
                                        ? 'Restart monitoring of this device'
                                        : 'Pause monitoring of this device',
                                child: IconButton(
                                  icon:
                                      isPaused
                                          ? Icon(Icons.play_circle)
                                          : Icon(Icons.pause_circle),
                                  padding: EdgeInsets.all(0.0),
                                  constraints: BoxConstraints(),
                                  onPressed:
                                      isPaused ? onStartStream : onPauseStream,
                                ),
                              ),

                              const SizedBox(width: 8),

                              IconButton(
                                icon: Icon(Icons.clear),
                                padding: EdgeInsets.all(0.0),
                                constraints: BoxConstraints(),
                                onPressed: onDelete,
                              ),
                            ],
                          )
                          : ResponseTime(
                            milliseconds:
                                latestPingData?.response?.time?.inMilliseconds,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleOpenInBrowser(BuildContext context, DeviceModel device) async {
    try {
      final result = await launchUrlString('http://${device.ipAddress}');

      if (result == false && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          genericErrorSnackbar(
            context: context,
            message: 'Unable to open device configuration in browser',
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          genericErrorSnackbar(
            context: context,
            message:
                'An error occurred trying to open the device configuration in the browser.',
          ),
        );
      }
    }
  }
}
