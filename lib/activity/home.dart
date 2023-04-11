import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
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
            Button(text: "启动", action: () async {
              const permission = Permission.manageExternalStorage;
              final status = await permission.status;
              if (status.isGranted) {
                const intent = AndroidIntent(
                  package: "com.aniplex.kirarafantasia",
                  componentName: "com.google.firebase.MessagingUnityPlayerActivity",
                  action: "ACTION_MAIN",
                  category: "CATEGORY_LAUNCHER"
                );
                intent.launch();
              }
              else if (status.isPermanentlyDenied) {
                openAppSettings();
              }
              else {
                await permission.request();
              }
            }),
            const SizedBox(height: 12),
            Button(text: "设置", action: () {})
          ],
        )
      )
    );
  }
}
