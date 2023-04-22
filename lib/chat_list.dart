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

  bool chatExists(String chatName) {
    return _chatList.contains(chatName);
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
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                print("TextField value: ${_chatNameController.text}");
                Navigator.of(context).pop();
                setState(() {
                  _chatList.add(_chatNameController.text);
                  _saveChatList(_chatList);
                  _chatNameController.text = "";
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning! You have to insert forst OpenAI key.'),
          content: TextField(
            controller: _chatNameController,
          ),
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
      _chatList.removeAt(index);
      _saveChatList(_chatList);
    });
  }

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    _loadChats();
  }

  void _showDialog() async {
    String? chatKey = await Settings.readKey();
    if (chatKey != null) {
      // Do something
      _showFormDialog(context);
    } else {
      print("There is no OpenAI key");
      //_showWarning(context);
    }
    _showFormDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showDialog();
              //_showFormDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chatList.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(_chatList[index]),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            onDismissed: (direction) {
              String deletedItem = _chatList[index];
              _deleteItem(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted $deletedItem'),
                ),
              );
            },
            child: ListTile(
              title: Text(_chatList[index]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat(
                      chatName: _chatList[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
