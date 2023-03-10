import 'package:flutter/material.dart';

import './chat.dart';
import './settings.dart';

/*
void main() {
  runApp(MyApp());
}
*/

Future<void> main() async {
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
        length: 2,
        child: Scaffold(
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Center(child: Chat()),
              Center(child: Settings()),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            child: TabBar(
              isScrollable: false,
              labelColor: Colors.black,
              tabs: [
                Tab(text: "Chat", icon: Icon(Icons.chat_bubble)),
                Tab(text: "Settings", icon: Icon(Icons.settings)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
