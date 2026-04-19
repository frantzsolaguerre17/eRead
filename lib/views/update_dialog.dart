import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDialog {

  static void showUpdateAvailable(
      BuildContext context,
      String apkUrl,
      bool forceUpdate,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Mise à jour disponible 🚀"),
        content: const Text("Une nouvelle version est disponible"),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startDownload(context, apkUrl, forceUpdate);
            },
            child: const Text("TELECHARGER"),
          ),
        ],
      ),
    );
  }

  // ================= DOWNLOAD CONTROLLER =================

  static void _startDownload(
      BuildContext context,
      String url,
      bool forceUpdate,
      ) {
    double progress = 0.0;

    late StateSetter setStateDialog;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
            );
          },
        );
      },
    );

    _downloadApk(
      url,
      onProgress: (p) {
        progress = p;
        setStateDialog(() {});
      },
      onDone: (filePath) async {

        // 1. fermer dialog download
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await Future.delayed(const Duration(milliseconds: 300));

        // 2. ouvrir INSTALL
        _showInstall(context, filePath, forceUpdate);
      },
    );
  }

  // ================= DOWNLOAD =================

  static Future<void> _downloadApk(
      String url, {
        required Function(double) onProgress,
        required Function(String) onDone,
      }) async {
    try {
      final dio = Dio();

      //final tempPath = "/storage/emulated/0/Download/eRead_update.apk";
      final dir = await getExternalStorageDirectory();
      final tempPath = "${dir!.path}/eRead_update.apk";

      await dio.download(
        url,
        tempPath,
        onReceiveProgress: (r, t) {
          if (t != -1) {
            onProgress(r / t);
          }
        },
      );

      onDone(tempPath);

    } catch (e) {
      print("❌ ERROR: $e");
    }
  }

  // ================= INSTALL =================

  static void _showInstall(
      BuildContext context,
      String path,
      bool forceUpdate,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (_) => AlertDialog(
        title: const Text("Téléchargement terminé ✅"),
        content: const Text("Installer maintenant ?"),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Plus tard"),
            ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              OpenFilex.open(path);
            },
            child: const Text("INSTALL"),
          ),
        ],
      ),
    );
  }
}