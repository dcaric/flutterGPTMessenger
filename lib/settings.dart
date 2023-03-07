import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: Settings(),
  ));
}

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String myKeyText = "";
  String? myKey;

  Future<void> _saveKey(String myKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('myKey', myKey);
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
    _readKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        myKeyText = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your OpenAI Key',
                      hintText: 'Your OpenAI Key',
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
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
