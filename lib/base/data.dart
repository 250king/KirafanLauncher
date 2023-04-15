import 'package:shared_preferences/shared_preferences.dart';

class Data {
  static late SharedPreferences preferences;

  static void initPreferences() async {
    preferences= await SharedPreferences.getInstance();
  }
}
