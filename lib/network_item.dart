import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:pingadinga/editable_text_field.dart';
import 'package:pingadinga/hiccup.dart';
import 'package:pingadinga/hover_region.dart';
import 'package:pingadinga/latest_hiccup_timestamp.dart';
import 'package:pingadinga/models/device_model.dart';
import 'package:pingadinga/network_state_chip.dart';
import 'package:pingadinga/response_time.dart';

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

                VerticalDivider(),

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
                                child: IconButton(
                                  icon: Icon(Icons.drag_handle),
                                  padding: EdgeInsets.all(0.0),
                                  constraints: BoxConstraints(),
                                  onPressed: () {},
                                ),
                              ),

                              IconButton(
                                icon:
                                    isPaused
                                        ? Icon(Icons.play_circle)
                                        : Icon(Icons.pause_circle),
                                padding: EdgeInsets.all(0.0),
                                constraints: BoxConstraints(),
                                onPressed:
                                    isPaused ? onStartStream : onPauseStream,
                              ),

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
}
