import 'package:flutter/material.dart';
import 'package:kirafan_launcher/base/data.dart';

final data = Data.preferences;

class ConfigActivity extends StatefulWidget {
  const ConfigActivity({super.key});

  @override
  State<StatefulWidget> createState() => ConfigActivityState();
}

class ConfigActivityState extends State<ConfigActivity> {
  final api = TextEditingController(text: data.getString("api") ?? "");

  final asset = TextEditingController(text: data.getString("asset") ?? "");

  @override
  void dispose() {
    super.dispose();
    api.dispose();
    asset.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("配置"),
        actions: [
          IconButton(
            onPressed: () {
              data.setString("api", api.text);
              data.setString("asset", asset.text);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save),
          )
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: api,
              decoration: const InputDecoration(
                labelText: '服务器URL'
              )
            ),
            const SizedBox(height: 12),
            TextField(
              controller: asset,
              decoration: const InputDecoration(
                labelText: '资源库URL'
              )
            )
          ],
        )
      )
    );
  }

}
