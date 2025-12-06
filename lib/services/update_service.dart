import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:r_upgrade/r_upgrade.dart'; // 👇 Import mới
import 'package:flutter/material.dart';

class UpdateService {
  final String repoUrl =
      "https://api.github.com/repos/hansukedev/love_sync/releases/latest";

  Future<void> checkUpdate(BuildContext context) async {
    try {
      // 1. Lấy version hiện tại
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // 2. Lấy info từ GitHub
      final response = await http.get(Uri.parse(repoUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestTag = data['tag_name'];
        String latestVersion = latestTag.replaceAll('v', '');

        // Lấy link tải APK
        String downloadUrl = data['assets'][0]['browser_download_url'];

        // 3. So sánh
        if (latestVersion != currentVersion) {
          _showUpdateDialog(context, downloadUrl, latestTag);
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
        content: Text("Bấm cập nhật để tải về và cài đặt tự động."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runUpgrade(url); // 👇 Gọi hàm cài mới
            },
            child: Text("Cập nhật ngay"),
          ),
        ],
      ),
    );
  }

  // 👇 Hàm chạy cập nhật bằng r_upgrade
  Future<void> _runUpgrade(String url) async {
    try {
      // Nó sẽ tự hiện thanh thông báo trên thanh trạng thái (Notification bar)
      await RUpgrade.upgrade(
        url,
        fileName: 'love_sync_update.apk',
        installType: RUpgradeInstallType
            .normal, // Tự động bung cửa sổ cài đặt khi tải xong
        notificationStyle:
            NotificationStyle.speechAndPlanTime, // Kiểu thông báo đẹp
      );
    } catch (e) {
      debugPrint('Lỗi update: $e');
    }
  }
}
