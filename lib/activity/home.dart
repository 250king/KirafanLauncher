// ignore_for_file: use_build_context_synchronously
import 'dart:isolate';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:app_to_foreground/app_to_foreground.dart';
import 'package:need_resume/need_resume.dart';
import 'package:shared_storage/saf.dart' as saf;
import 'package:kirafan_launcher/base/data.dart';
import 'package:kirafan_launcher/base/file.dart';
import 'package:kirafan_launcher/components/button.dart';
import 'package:kirafan_launcher/components/dialog/background.dart';
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

  void start () async {
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
        if (storageStatus.isGranted) {
          late PermissionStatus manageStatus;
          final base = "Android/data/${widget.package}/files/il2cpp/metadata";
          if (os.version.sdkInt >= 30) {
            manageStatus = await Permission.manageExternalStorage.request();
            if (manageStatus.isGranted) {
              final list = await saf.persistedUriPermissions() ?? [];
              if (list.isNotEmpty) {
                final result = await BackgroundDialog.show(context) ?? false;
                if (result) {
                  final token = RootIsolateToken.instance!;
                  Isolate.spawn(FIleHelper.modify11, {
                    "file": await saf.fromTreeUri(list[0].uri),
                    "api": api,
                    "asset": asset,
                    "token": token
                  });
                  InstalledApps.startApp(widget.package);
                }
              }
              else {
                InstalledApps.startApp(widget.package);
                InstalledApps.toast("由于系统限制，需要进一步授权。请等待10秒钟后继续，期间不要退出游戏", true);
                Timer(const Duration(seconds: 5), () async {
                  final path = 'content://com.android.externalstorage.documents/tree/primary%3A${Uri.encodeComponent(base)}';
                  InstalledApps.toast("请选中文件完成授权", true);
                  final selector = await saf.openDocument(
                      initialUri: Uri.parse(path)
                  ) ?? [];
                  AppToForeground.appToForeground();
                  if (selector.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("授权成功！请清理后台后再次启动游戏")
                    ));
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("很抱歉，我们需要文件访问权限，请再次尝试授权")
                    ));
                  }
                });
              }
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("很抱歉，我们需要文件访问权限，请再次尝试授权")
              ));
            }
          }
          else {
            final result = await BackgroundDialog.show(context) ?? false;
            if (result) {
              Isolate.spawn(FIleHelper.modify, {
                "file": File("/sdcard/$base/global-metadata.dat"),
                "api": api,
                "asset": asset
              });
              InstalledApps.startApp(widget.package);
            }
          }
        }
        else if (storageStatus.isPermanentlyDenied) {
          InstalledApps.toast("由于您永久拒绝授予文件访问权限，需要手动在在在应用设置允许访问全部文件", true);
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
  }

  @override
  void onResume() {
    checkApp();
  }

  @override
  void initState() {
    checkApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final list = [
      Button(
          text: "配置",
          icon: Icons.mode,
          action: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return const ConfigActivity();
            }));
          }
      ),
      Button(
          text: version.isEmpty? "安装应用": "应用已安装",
          subtext: version.isEmpty? "": "v$version",
          icon: Icons.videogame_asset,
          action: () {
            if (version.isEmpty) {
              const url = "https://s1.250king.top/achieve/%E3%81%8D%E3%82%89%E3%82%89%E3%83%95%E3%82%A1%E3%83%B3%E3%82%BF%E3%82%B8%E3%82%A2_3.6.0_Apkpure.apk";
              launch(url, customTabsOption: const CustomTabsOption(
                  enableDefaultShare: false
              ));
            }
          }
      ),
      Button(text: "启动", icon: Icons.play_arrow, action: start)
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kirafan Launcher"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemBuilder: (BuildContext context, int index) {
          return list[index];
        },
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 12);
        },
        itemCount: list.length
      )
    );
  }
}
