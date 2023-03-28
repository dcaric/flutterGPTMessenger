import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import './chat.dart';
import './settings.dart';
import './login.dart';
import './sign_up_page.dart';

/*
void main() {
  runApp(MyApp());
}
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ideal time to initialize
  //await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Center(child: Chat()),
              Center(child: Settings()),
              Center(child: SignUpPage()),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: TabBar(
              isScrollable: false,
              labelColor: Colors.black,
              tabs: [
                Tab(text: "Chat", icon: Icon(Icons.chat_bubble)),
                Tab(text: "Settings", icon: Icon(Icons.settings)),
                Tab(text: "Login", icon: Icon(Icons.login)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
