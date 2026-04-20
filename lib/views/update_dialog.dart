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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.system_update, size: 32, color: Colors.deepPurple),
              ),
              const SizedBox(height: 12),

              const Text(
                "Mise à jour disponible",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "Une nouvelle version est prête à être installée 🚀",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _startDownload(context, apkUrl, forceUpdate);
                  },
                  child: const Text("TÉLÉCHARGER", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
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

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Téléchargement en cours...",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Téléchargement de la mise à jour...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
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
      barrierDismissible: false, // 🔒 empêche clic extérieur
      builder: (_) => WillPopScope(
        onWillPop: () async => false, // 🔒 bloque bouton retour
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 32, color: Colors.green),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Téléchargement terminé",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Installer la nouvelle version maintenant ?",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      OpenFilex.open(path);
                    },
                    child: const Text(
                      "INSTALLER",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}