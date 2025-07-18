import 'package:pingadinga/models/device_model.dart';

Map<String, DeviceModel> createMockDevices() {
  return {
    '1': DeviceModel(
      uid: '1',
      ipAddress: 'www.google.com',
      name: 'Google Machine',
    ),

    '2': DeviceModel(
      uid: '2',
      ipAddress: 'www.apple.com',
      name: 'Apple Machine',
    ),

    '3': DeviceModel(uid: '3', ipAddress: '192.168.0.1', name: 'Routerniss'),

    '4': DeviceModel(uid: '4', ipAddress: '192.168.0.243', name: 'Vacniss?'),

    '5': DeviceModel(uid: '5', ipAddress: '192.168.0.33', name: 'Phone'),
  };
}
