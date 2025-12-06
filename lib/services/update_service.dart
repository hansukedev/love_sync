import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class UpdateService {
  final String repoUrl =
      "https://api.github.com/repos/hansukedev/love_sync/releases/latest";

  Future<void> checkUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(repoUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestTag = data['tag_name'];
        String latestVersion = latestTag.replaceAll('v', '');
        String downloadUrl = data['assets'][0]['browser_download_url'];

        // Debug log
        debugPrint("Current: $currentVersion, Latest: $latestVersion");

        if (latestVersion != currentVersion) {
          if (context.mounted) {
            _showUpdateDialog(context, downloadUrl, latestTag);
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi check update: $e");
    }
  }

  void _showUpdateDialog(BuildContext context, String url, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Có bản cập nhật mới! ($version)"),
        content: Text("Bấm cập nhật để tải về và cài đặt."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(context, url);
            },
            child: Text("Cập nhật ngay"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(BuildContext context, String url) async {
    // 1. Xin quyền (Chủ yếu cho Android < 10)
    var status = await Permission.storage.request();
    if (status.isDenied) {
      debugPrint("Không có quyền ghi file");
      return;
    }

    // Hiển thị loading (đơn giản)
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang tải bản cập nhật... Vui lòng đợi.")),
      );
    }

    try {
      // 2. Xác định đường dẫn lưu file
      // Dùng getExternalCacheDirectories an toàn hơn cho việc cài đặt
      Directory? tempDir = await getExternalStorageDirectory();
      // Nếu null thì fallback về temporary
      tempDir ??= await getTemporaryDirectory();

      String savePath = "${tempDir.path}/love_sync_update.apk";

      // 3. Tải file bằng Dio
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              "Download: ${(received / total * 100).toStringAsFixed(0)}%",
            );
            // Bạn có thể update UI progress bar ở đây nếu muốn
          }
        },
      );

      debugPrint("Tải xong: $savePath");

      // 4. Mở file để cài đặt
      final result = await OpenFile.open(savePath);
      debugPrint("Open result: ${result.type} - ${result.message}");

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi mở file: ${result.message}")),
          );
        }
      }
    } catch (e) {
      debugPrint("Lỗi download/install: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    }
  }
}
