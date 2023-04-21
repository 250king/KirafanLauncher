import 'package:flutter/material.dart';

class BackgroundDialog {
  static Future<bool?> show(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("提示"),
          content: const Text("请确保已经清除了游戏的后台，否则无法启动游戏。\n确认后台已经清理后即可继续操作。"),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  color: Colors.red
                )
              ),
              child: const Text("取消"),
              onPressed: () {
                Navigator.of(context).pop(false);
              }
            ),
            TextButton(
              child: const Text("继续"),
              onPressed: () {
                Navigator.of(context).pop(true);
              }
            )
          ]
        );
      }
    );
  }
}
