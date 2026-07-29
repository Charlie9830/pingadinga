import 'package:dart_ping/dart_ping.dart';
import 'package:pingadinga/models/list_item_model.dart';

class DeviceViewModel {
  final PingEvent ping;
  final DeviceModel device;

  DeviceViewModel({required this.ping, required this.device});
}
