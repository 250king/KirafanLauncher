// ignore_for_file: use_build_context_synchronously
import 'dart:isolate';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:need_resume/need_resume.dart';
import 'package:kirafan_launcher/base/data.dart';
import 'package:kirafan_launcher/base/file.dart';
import 'package:kirafan_launcher/components/button.dart';
import 'package:kirafan_launcher/activity/config.dart';

final data = Data.preferences;

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  final package = "com.aniplex.kirarafantasia";

  @override
  State<HomeActivity> createState() => HomeActivityState();
}

class HomeActivityState extends ResumableState<HomeActivity> {
  String version = "";

  void checkApp() {
    InstalledApps.getAppInfo(widget.package).then((result) {
      setState(() {
        version = result.versionName ?? "";
      });
    }).catchError((error) {
      setState(() {
        version =  "";
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    checkApp();
  }

  @override
  void initState() {
    checkApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kirafan Launcher"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Button(
            text: "配置",
            action: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ConfigActivity();
              }));
            }
          ),
          const SizedBox(height: 12),
          Button(
            text: version.isEmpty? "安装应用": "应用已安装（v$version）",
            action: () {
              if (version.isEmpty) {
                const url = "https://kirafan-asset-cn-shenzhen.oss-cn-shenzhen.aliyuncs.com/apk/%E3%81%8D%E3%82%89%E3%82%89%E3%83%95%E3%82%A1%E3%83%B3%E3%82%BF%E3%82%B8%E3%82%A2_3.6.0_Apkpure.apk";
                launch(url, customTabsOption: const CustomTabsOption(
                  enableDefaultShare: false
                ));
              }
            }
          ),
          const SizedBox(height: 12),
          Button(text: "启动", action: () async {
            final api = data.getString("api") ?? "";
            final asset = data.getString("asset") ?? "";
            if (api.isEmpty || asset.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("您还没设置相关配置，请先设置相关配置后再尝试启动")
              ));
            }
            else {
              if (version.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("您还没安装应用，请先安装应用后再尝试启动")
                ));
              }
              else if (version == "3.6.0") {
                final device = DeviceInfoPlugin();
                final os = await device.androidInfo;
                final storageStatus = await Permission.storage.request();
                late PermissionStatus manageStatus;
                if (os.version.sdkInt >= 30) {
                  manageStatus = await Permission.manageExternalStorage.request();
                }
                if ((os.version.sdkInt >= 30 && storageStatus.isGranted && manageStatus.isGranted) || storageStatus.isGranted) {
                  if (os.version.sdkInt >= 30) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("暂不支持Android 11及以上版本，我们也尽快适配")
                    ));
                  }
                  else {
                    final receivePort = ReceivePort();
                    Isolate.spawn(FIleHelper.modify, receivePort.sendPort);
                    final sendPort = await receivePort.first;
                    sendPort.send({
                      "file": File("/sdcard/Android/data/${widget.package}/files/il2cpp/metadata/global-metadata.dat"),
                      "api": api,
                      "asset": asset
                    });
                  }
                  InstalledApps.startApp(widget.package);
                }
                else if ((os.version.sdkInt >= 30 && manageStatus.isPermanentlyDenied) || storageStatus.isPermanentlyDenied) {
                  InstalledApps.toast("由于您永久拒绝授予文件访问权限，需要手动在在在应用设置允许文件访问", true);
                  openAppSettings();
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("很抱歉，我们需要文件访问权限，请再次尝试授权")
                  ));
                }
              }
              else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("很抱歉，目前仅支持版本3.6.0，请删除版本有误的应用后重新安装")
                ));
              }
            }
          })
        ]
      )
    );
  }
}
