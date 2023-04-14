import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kirafan_launcher/components/button.dart';
import 'package:kirafan_launcher/activity/config.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => HomeActivityState();
}

class HomeActivityState extends State<HomeActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kirafan Launcher"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Button(
              text: "配置",
              action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ConfigActivity();
                }));
              }
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              child: const Text("应用")
            ),
            const SizedBox(height: 12),
            Button(text: "启动", action: () async {
              final device = DeviceInfoPlugin();
              final os = await device.androidInfo;
              late PermissionStatus status;
              if (os.version.sdkInt >= 30) {
                status = await Permission.manageExternalStorage.request();
              }
              else {
                status = await Permission.storage.request();
              }
              if (status == PermissionStatus.granted) {
                const intent = AndroidIntent(
                  package: "com.aniplex.kirarafantasia",
                  componentName: "com.google.firebase.MessagingUnityPlayerActivity",
                  action: "ACTION_MAIN",
                  category: "CATEGORY_LAUNCHER"
                );
                intent.launch();
              }
              else if (status.isPermanentlyDenied) {
                Fluttertoast.showToast(msg: "由于您永久拒绝授予文件访问权限，需要手动在在在应用设置允许文件访问");
                openAppSettings();
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("很抱歉，我们需要文件访问权限，请再次尝试授权")
                ));
              }
            }),
          ],
        )
      )
    );
  }
}
