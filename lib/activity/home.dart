import 'package:flutter/material.dart';
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
            Button(text: "启动", action: () {}),
            const SizedBox(height: 12),
            Button(text: "设置", action: () {})
          ],
        )
      )
    );
  }
}
