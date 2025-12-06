import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter/material.dart';

class UpdateService {
  // Thay username và tên repo của bạn vào đây
  final String repoUrl =
      "https://api.github.com/repos/hansukedev/love_sync/releases/latest";

  Future<void> checkUpdate(BuildContext context) async {
    try {
      // 1. Lấy version hiện tại trong máy
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // Ví dụ: 1.0.0

      // 2. Lấy version mới nhất từ GitHub
      final response = await http.get(Uri.parse(repoUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestTag = data['tag_name']; // Ví dụ: v1.0.1
        // Xóa chữ 'v' nếu có để so sánh số
        String latestVersion = latestTag.replaceAll('v', '');

        // Lấy link tải file .apk đầu tiên trong assets
        String downloadUrl = data['assets'][0]['browser_download_url'];

        // 3. So sánh (Logic đơn giản: Khác nhau là update.
        // Muốn xịn hơn thì dùng so sánh semantic versioning)
        if (latestVersion != currentVersion) {
          _showUpdateDialog(context, downloadUrl, latestTag);
        }
      }
    } catch (e) {
      print("Lỗi check update: $e");
    }
  }

  void _showUpdateDialog(BuildContext context, String url, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Có bản cập nhật mới! ($version)"),
        content: Text("Cập nhật ngay để có tính năng mới và fix lỗi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runOTA(url); // Chạy cập nhật
            },
            child: Text("Cập nhật ngay"),
          ),
        ],
      ),
    );
  }

  // Hàm tải và cài đặt tự động
  Future<void> _runOTA(String url) async {
    try {
      // Lắng nghe tiến trình tải
      OtaUpdate()
          .execute(
            url,
            destinationFilename: 'love_sync_update.apk', // Tên file tạm
          )
          .listen((OtaEvent event) {
            // Bạn có thể update UI thanh loading ở đây dựa vào event.value
            print('Status: ${event.status}, Progress: ${event.value}%');
          });
    } catch (e) {
      print('Lỗi OTA: $e');
    }
  }
}
