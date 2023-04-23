import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MaterialApp(
    home: Settings(),
    debugShowCheckedModeBanner: false, // Add this line
  ));
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();

  static Future<String?> readKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('myKey');
    print("myValue:$value");
    return value;
  }

  static Future<void> saveKey(String keyToSave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('myKey', keyToSave);
  }
}

class _SettingsState extends State<Settings> {
  String myKeyText = "";
  String? myKey;

  Future<void> _saveKey(String keyToSave) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('myKey', keyToSave);
    setState(() {
      myKey = keyToSave;
    });
  }

  Future<void> _readKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('myKey');
    print("myValue:$value");
    setState(() {
      myKey = value;
    });
  }

  void initState() {
    super.initState();
    // perform some action when the widget is displayed
    // just for now save key
    _readKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 98, 73, 9),
          title: Text('Settings'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
                    onChanged: (value) {
                      setState(() {
                        myKeyText = value;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your OpenAI Key',
                      hintText: 'Your OpenAI Key',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 98, 73, 9)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text("SAVE"),
                  onPressed: () async {
                    _saveKey(myKeyText);
                    print("** myKey: $myKey");
                  },
                ),
                Icon(Icons.key),
                SizedBox(width: 8),
                // ignore: unnecessary_null_comparison
                Text(myKey != null ? 'Key is saved' : 'Key not save jet!'),
              ],
            )));
  }
}
