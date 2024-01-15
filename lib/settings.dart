import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double fontSize = 16;

  Future<void> _saveFontSize(double fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
    print("SAVE font size: $fontSize");
  }

  Future<void> _readFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? value = prefs.getDouble('fontSize');
    print("font size: $value");
    setState(() {
      fontSize = value ?? 16;
    });
    print("READ font size: $fontSize");
  }

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
    //print("** myKey value: $value");

    setState(() {
      myKey = value;
    });
  }

  void initState() {
    super.initState();
    // perform some action when the widget is displayed
    // just for now save key
    _readKey();
    _readFontSize();
  }

  void _increaseFontSize() {
    setState(() {
      fontSize += 1.0;
      _saveFontSize(fontSize);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      fontSize -= 1.0;
      _saveFontSize(fontSize);
    });
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
                style: TextStyle(fontSize: fontSize),
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
                backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 98, 73, 9)),
                foregroundColor: MaterialStateProperty.all(Colors.white),
              ),
              child: Text("SAVE"),
              onPressed: () async {
                _saveKey(myKeyText);
                print("** myKey: $myKey");
              },
            ),
            Icon(Icons.key),
            SizedBox(height: 8),
            // ignore: unnecessary_null_comparison
            Text(myKey != null ? 'Key is saved' : 'Key not save jet!', style: TextStyle(fontSize: fontSize)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 98, 73, 9)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: _decreaseFontSize,
                      child: Icon(Icons.remove),
                    ),
                    Text(
                      'Decrease font',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 98, 73, 9)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      onPressed: _increaseFontSize,
                      child: Icon(Icons.add),
                    ),
                    Text(
                      'Increase font',
                      style: TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
