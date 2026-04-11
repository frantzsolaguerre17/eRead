import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UpdateDialog {

  /// 🔔 1. Popup nouvelle version
  static void showUpdateAvailable(
      BuildContext context,
      String apkUrl,
      bool forceUpdate,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => AlertDialog(
        title: const Text("Mise à jour disponible 🚀"),
        content: const Text("Une nouvelle version est disponible"),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Plus tard"),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showDownloadingDialog(context, apkUrl, forceUpdate);
            },
            child: const Text("TELECHARGER"),
          ),
        ],
      ),
    );
  }

  /// ⬇️ 2. Dialog téléchargement
  static void showDownloadingDialog(
      BuildContext context,
      String apkUrl,
      bool forceUpdate,
      ) {
    double progress = 0.0;
    bool isBackground = false;

    late StateSetter setStateDialog;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            setStateDialog = setState;

            return AlertDialog(
              title: const Text("Téléchargement..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 10),
                  Text("${(progress * 100).toStringAsFixed(0)}%"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    isBackground = true;
                    Navigator.pop(context);
                  },
                  child: const Text("Arrière-plan"),
                ),
              ],
            );
          },
        );
      },
    );

    _downloadApk(
      apkUrl,
      onProgress: (p) {
        progress = p;
        if (!isBackground) {
          setStateDialog(() {});
        }
      },
        onComplete: (path) {
          Navigator.of(context, rootNavigator: true).pop();
          showInstallDialog(context, path, forceUpdate);
        }
    );
  }

  /// 📥 3. Téléchargement APK
  static Future<void> _downloadApk(
      String url, {
        required Function(double) onProgress,
        required Function(String) onComplete,
      }) async {
    try {
      // 🔐 Permission stockage
      if (Platform.isAndroid) {
        if (!await Permission.storage.isGranted) {
          await Permission.storage.request();
        }
      }

      // 📁 Chemin public (VISIBLE)
      final dir = Directory('/storage/emulated/0/Download');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final path = '${dir.path}/eRead_update.apk';

      print("DOWNLOAD PATH: $path"); // debug

      final dio = Dio();

      await dio.download(
        url,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            print("PROGRESS: $received / $total");
            onProgress(progress);
          }
        },
      );

      // ✅ Vérification
      if (File(path).existsSync()) {
        print("APK téléchargé !");
        onComplete(path);
      } else {
        print("ERREUR: fichier non trouvé");
      }

    } catch (e) {
      print("ERREUR DOWNLOAD: $e");
    }
  }

  /// 📦 4. INSTALL
  static void showInstallDialog(
      BuildContext context,
      String path,
      bool forceUpdate,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => AlertDialog(
        title: const Text("Téléchargement terminé"),
        content: const Text("Installer la mise à jour ?"),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Plus tard"),
            ),

          /// 🔥 BOUTON INSTALL
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              /// 👉 C'EST ICI
              OpenFilex.open(path);
            },
            child: const Text("INSTALL"),
          ),
        ],
      ),
    );
  }
}