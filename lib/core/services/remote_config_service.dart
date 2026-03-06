import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      'min_required_version': '1.0.0',
      'latest_version': '1.0.0',
    });
    
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      print('Remote Config fetch failed: $e');
    }
  }

  String get minRequiredVersion => _remoteConfig.getString('min_required_version');
  String get latestVersion => _remoteConfig.getString('latest_version');

  Future<bool> isUpdateRequired() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    return _isVersionLower(currentVersion, minRequiredVersion);
  }

  Future<bool> isUpdateAvailable() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    return _isVersionLower(currentVersion, latestVersion);
  }

  bool _isVersionLower(String current, String target) {
    List<int> currentParts = current.split('.').map(int.parse).toList();
    List<int> targetParts = target.split('.').map(int.parse).toList();

    for (int i = 0; i < targetParts.length; i++) {
        int currentPart = i < currentParts.length ? currentParts[i] : 0;
        if (currentPart < targetParts[i]) return true;
        if (currentPart > targetParts[i]) return false;
    }
    return false;
  }
}
