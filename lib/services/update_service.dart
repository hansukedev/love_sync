import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class UpdateService {
  final String repoUrl =
      "https://api.github.com/repos/hansukedev/love_sync/releases/latest";

  Future<void> checkUpdate(BuildContext context) async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // Ví dụ: 1.0.0

      debugPrint("🔍 Đang kiểm tra update... (Current: $currentVersion)");

      final response = await http.get(Uri.parse(repoUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String latestTag = data['tag_name'];
        // Xử lý chuỗi version: Xóa chữ 'v', xóa khoảng trắng
        String latestV = latestTag.replaceAll('v', '').trim();
        String currentV = currentVersion.replaceAll('v', '').trim();

        String downloadUrl = data['assets'][0]['browser_download_url'];

        debugPrint("📡 Check Version: Server($latestV) vs App($currentV)");

        // So sánh version strict
        if (latestV != currentV) {
          debugPrint("🚀 Có bản mới! Hiển thị dialog...");
          if (context.mounted) {
            _showUpdateDialog(context, downloadUrl, latestTag);
          }
        } else {
          debugPrint("✅ App đang ở phiên bản mới nhất.");
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi check update: $e");
    }
  }

  void _showUpdateDialog(BuildContext context, String url, String version) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Cập nhật Love Sync $version"),
        content: const Text(
          "Phiên bản mới đã sẵn sàng. Tải ngay để fix lỗi và thêm tính năng mới!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Để sau"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadAndInstall(context, url);
            },
            child: const Text("Cập nhật ngay"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndInstall(BuildContext context, String url) async {
    // 1. Không cần xin quyền Storage nếu dùng cache directory (Android 11+ safe)

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🚀 Đang tải bản cập nhật... Vui lòng không tắt app."),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      // 2. Xác định đường dẫn lưu file
      // FIX: Dùng getApplicationCacheDirectory để tránh lỗi Permission Denied trên Android mới
      // getExternalCacheDirectory ưu tiên thẻ nhớ ngoài, getApplicationCacheDirectory ưu tiên bộ nhớ trong
      final Directory cacheDir = await getApplicationCacheDirectory();
      String savePath = "${cacheDir.path}/love_sync_update.apk";

      debugPrint("📂 Lưu file tại: $savePath");

      // Xóa file cũ nếu có
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      // 3. Tải file bằng Dio
      debugPrint("🚀 Bắt đầu tải...");
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            String percent = (received / total * 100).toStringAsFixed(0);
            debugPrint("📦 Download: $percent% ($received/$total)");
          }
        },
      );

      debugPrint("✅ Tải xong! Đang mở file...");

      // 4. Mở file cài đặt
      final result = await OpenFile.open(savePath);
      debugPrint("📦 Kết quả cài đặt: ${result.type} - ${result.message}");

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi mở file: ${result.message}")),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi download/install: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi tải: $e")));
      }
    }
  }
}
