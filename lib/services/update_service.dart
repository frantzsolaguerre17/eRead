import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../views/update_dialog.dart';

class UpdateService {
  static final supabase = Supabase.instance.client;

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final data = await supabase
          .from('app_config')
          .select()
          .limit(1);

      if (data.isEmpty) return;

      final config = data.first;

      final currentVersion =
          (await PackageInfo.fromPlatform()).version;

      final latestVersion = config['version'];
      final apkUrl = config['apk_url'];
      final forceUpdate = config['force_update'] ?? false;

      if (currentVersion != latestVersion) {
        UpdateDialog.showUpdateAvailable(
          context,
          apkUrl,
          forceUpdate,
        );
      }
    } catch (e) {
      print("Erreur update: $e");
    }
  }
}