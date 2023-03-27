import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
                    enableInteractiveSelection: true,
                    enableSuggestions: true,
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
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text("Firestore"),
                  onPressed: () async {
                    WidgetsFlutterBinding.ensureInitialized();
                    await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    );
                    // Ideal time to initialize
                    //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

                    FirebaseAuth.instance
                        .authStateChanges()
                        .listen((User? user) {
                      if (user == null) {
                        print('User is currently signed out!');
                      } else {
                        print('User is signed in!');
                      }
                    });
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
