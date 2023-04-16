import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:need_resume/need_resume.dart';
import 'package:shared_storage/saf.dart';
import 'package:kirafan_launcher/base/data.dart';
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

  void write(RandomAccessFile file, String origin, String replace, int position) async {
    final length = origin.length;
    file.setPosition(position);
    final raw = await file.read(length);
    if (raw != utf8.encode(replace)) {
      if (raw == utf8.encode(origin)) {
        file.setPosition(position);
        file.writeFrom(utf8.encode(replace));
      }
    }
  }

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
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
              action: () async {
                if (version.isEmpty) {
                  const url = "https://kirafan-asset-cn-shenzhen.oss-cn-shenzhen.aliyuncs.com/apk/%E3%81%8D%E3%82%89%E3%82%89%E3%83%95%E3%82%A1%E3%83%B3%E3%82%BF%E3%82%B8%E3%82%A2_3.6.0_Apkpure.apk";
                  await launch(url, customTabsOption: const CustomTabsOption(
                    enableDefaultShare: false
                  ));
                }
              }
            ),
            const SizedBox(height: 12),
            Button(text: "启动", action: () async {
              if (version.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("您还没安装应用，请先安装应用后再尝试启动")
                ));
              }
              else if (version == "3.6.0") {
                final device = DeviceInfoPlugin();
                final os = await device.androidInfo;
                late PermissionStatus status;
                String dir = "";
                if (os.version.sdkInt >= 30) {
                  status = await Permission.manageExternalStorage.request();
                }
                else {
                  status = await Permission.storage.request();
                }
                if (status.isGranted && dir.isNotEmpty) {
                  InstalledApps.startApp(widget.package);
                  if (os.version.sdkInt >= 30) {
                    InstalledApps.toast("请等待5秒钟后继续授权，等待期间不要退出游戏", true);
                    Timer.periodic(const Duration(seconds: 5), (t) async {
                      final saf = await openDocument(
                        initialUri: Uri.file("/storage/emulated/0/android/data/${widget.package}/files/il2cpp/Metadata")
                      );
                    });
                  }
                  /*
                  final time = DateTime.now().millisecondsSinceEpoch / 1000;
                  print("begin");
                  while (DateTime.now().millisecondsSinceEpoch / 1000 - time <= 30) {
                    write(file, "krr-prd.star-api.com", data.getString("api") ?? "krr-prd.star-api.com", int.parse("4A403",radix: 16));
                    write(file, "asset-krr-prd.star-api.com/{0}", data.getString("asset") ?? "asset-krr-prd.star-api.com/{0}", int.parse("1D36E", radix: 16));
                  }
                  print("end");
                  */
                }
                else if (status.isPermanentlyDenied) {
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
            }),
          ],
        )
      )
    );
  }
}
