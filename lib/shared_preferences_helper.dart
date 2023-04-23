import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<String?> readKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('myKey');
    return value;
  }
}
