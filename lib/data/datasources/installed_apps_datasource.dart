import 'package:flutter/services.dart';
import 'package:apex_booster_plus/domain/entities/installed_app.dart';

class InstalledAppsDatasource {
  static const _channel =
      MethodChannel('com.allappsengineer.apex_booster_plus/apps');

  Future<List<InstalledApp>> getInstalledApps() async {
    final List<dynamic> raw =
        await _channel.invokeMethod('getInstalledApps');
    return raw
        .map((e) => InstalledApp.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
