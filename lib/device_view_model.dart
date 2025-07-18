import 'package:dart_ping/dart_ping.dart';
import 'package:pingadinga/models/device_model.dart';

class DeviceViewModel {
  final PingData ping;
  final DeviceModel device;

  DeviceViewModel({required this.ping, required this.device});
}
