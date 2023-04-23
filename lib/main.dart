import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

import './chat.dart';
import './settings.dart';
import './login.dart';
import './sign_up_page.dart';
import './chat_list.dart';
import './settings.dart';

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
  String keyPart1 = "sk-8xHDB5r9dXaYcPjIAXkVT3Blbk";
  String keyPart2 = "FJMdfa58rewljdROwH0OYF";

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    _saveKey();
  }

  void _saveKey() async {
    Settings.saveKey(keyPart1 + keyPart2);
    print("API KEY:${Settings.readKey()}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Add this line to hide the Debug banner
      theme: ThemeData(
        textTheme: GoogleFonts.notoSansTextTheme(
          Theme.of(context).textTheme,
        ),
        primaryColor: Color.fromARGB(255, 98, 73, 9),
        scaffoldBackgroundColor: Color.fromARGB(255, 225, 218, 208),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(child: ChatList()),
              Center(child: Settings()),
              Center(child: SignUpPage()),
            ],
          ),
          bottomNavigationBar: const BottomAppBar(
            color: Color.fromARGB(255, 98, 73, 9),
            child: TabBar(
              isScrollable: false,
              labelColor: Colors.white,
              tabs: [
                Tab(text: "Chats", icon: Icon(Icons.chat_bubble)),
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
