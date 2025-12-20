import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StageDeviceCapability { high, medium, low }

extension StageDeviceCapabilityLabel on StageDeviceCapability {
  String get label => switch (this) {
        StageDeviceCapability.high => '高性能设备',
        StageDeviceCapability.medium => '标准设备',
        StageDeviceCapability.low => '入门设备',
      };
}

final stageDeviceCapabilityProvider =
    FutureProvider<StageDeviceCapability>((ref) async {
      if (kIsWeb) {
        return StageDeviceCapability.high;
      }
      final plugin = DeviceInfoPlugin();
      try {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            final info = await plugin.androidInfo;
            final sdk = info.version.sdkInt;
            final abis = info.supportedAbis;
            final has64Bit =
                abis.any((abi) => abi.toLowerCase().contains('64')) ||
                abis.any((abi) => abi.toLowerCase().contains('armv8'));
            if (has64Bit && sdk >= 31) return StageDeviceCapability.high;
            if (sdk >= 28) return StageDeviceCapability.medium;
            return StageDeviceCapability.low;
          case TargetPlatform.iOS:
            final info = await plugin.iosInfo;
            final majorVersion =
                int.tryParse(info.systemVersion.split('.').first) ?? 0;
            if (majorVersion >= 16) return StageDeviceCapability.high;
            if (majorVersion >= 14) return StageDeviceCapability.medium;
            return StageDeviceCapability.low;
          case TargetPlatform.macOS:
          case TargetPlatform.windows:
          case TargetPlatform.linux:
            return StageDeviceCapability.high;
          case TargetPlatform.fuchsia:
            return StageDeviceCapability.medium;
        }
      } catch (_) {
        // ignore failures and fallback
      }
      return StageDeviceCapability.medium;
    });
