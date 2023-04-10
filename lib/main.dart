import 'package:flutter/material.dart';
import 'package:kirafan_launcher/base/data.dart';
import 'package:kirafan_launcher/activity/home.dart';

void main() {
  runApp(const App());
  Data.initPreferences();
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kirafan Launcher',
      theme: ThemeData(useMaterial3: true),
      home: const HomeActivity(),
    );
  }
}

