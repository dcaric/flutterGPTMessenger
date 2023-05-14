import 'package:GPTmsg/settings.dart';
import 'package:flutter/material.dart';
import './chat.dart';
import './settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<String> _chatList = [];
  TextEditingController _chatNameController = TextEditingController();
  final Settings settings = const Settings();
  TextEditingController _searchController = TextEditingController();

  double fontSize = 16;

  // search
  List<String> _filteredChatList() {
    if (_searchController.text.isEmpty) {
      return _chatList;
    }

    return _chatList.where((chat) => chat.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
  }

  bool chatExists(String chatName) {
    return _chatList.contains(chatName);
  }

  Future<void> deleteSingleKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> _saveChatList(List<String> chatList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatListJson = jsonEncode(chatList);
    prefs.setString('chats', chatListJson);
    setState(() {
      _chatList = chatList;
    });
  }

  Future<List<String>?> _readChatList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatListJson = prefs.getString('chats');

    if (chatListJson != null) {
      List<String> chatList = List<String>.from(jsonDecode(chatListJson));
      print("chatList:$chatList");
      setState(() {
        _chatList = chatList;
      });
      return chatList;
    }
    return null;
  }

  Future<void> _loadChats() async {
    List<String>? chatList = await _readChatList();

    if (chatList != null && chatList.isNotEmpty) {
      setState(() {
        _chatList = chatList;
      });
    }
  }

  Future<void> _readFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? value = prefs.getDouble('fontSize');
    setState(() {
      fontSize = value ?? 16;
    });
    print("font size: $value");
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Chat'),
          content: TextField(
            controller: _chatNameController,
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                primary: Color.fromARGB(255, 98, 73, 9),
              ),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                print("TextField value: ${_chatNameController.text}");
                Navigator.of(context).pop();
                if (_chatNameController.text != "" && !chatExists(_chatNameController.text)) {
                  setState(() {
                    _chatList.add(_chatNameController.text);
                    _saveChatList(_chatList);
                    _chatNameController.text = "";
                  });
                } else if (chatExists(_chatNameController.text)) {
                  _showWarning(context, "This chat already exists");
                }
              },
              style: TextButton.styleFrom(
                primary: Color.fromARGB(255, 98, 73, 9),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showWarning(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      deleteSingleKey(_chatList[index]);
      _chatList.removeAt(index);
      _saveChatList(_chatList);
    });
  }

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    _loadChats();
    _readFontSize();
  }

  void _showDialog() async {
    String? chatKey = await Settings.readKey();
    if (chatKey != null) {
      // Do something
      _showFormDialog(context);
    } else {
      print("There is no OpenAI key");
      _showWarning(context, 'Warning! You have to insert first OpenAI key.');
    }
    //_showFormDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 98, 73, 9),
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredChatList().length, // Use the filtered list here
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_filteredChatList()[index]), // Use the filtered list here
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (direction) {
                    String deletedItem = _filteredChatList()[index]; // Use the filtered list here
                    _deleteItem(_chatList.indexOf(deletedItem));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted $deletedItem'),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      _filteredChatList()[index],
                      style: TextStyle(
                        //color: widget.isMe ? Colors.white : Colors.black,
                        fontSize: fontSize,
                      ),
                    ), // Use the filtered list here
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            chatName: _filteredChatList()[index], // Use the filtered list here
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
