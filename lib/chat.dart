//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:messenger_demo/http_request.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './popup.dart';
import 'package:flutter/services.dart';
import './message_buble.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _listLength = ValueNotifier<int>(0);

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final PopupMenuExample _popup = const PopupMenuExample();

  double _keyboardHeight = 0.0;

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    /*
    _focusNode.addListener(() {
      print('Listener');
    });*/
    _loadList();

/*
    _focusNode.addListener(() {
      print('Focus changed: ${_focusNode.hasFocus}');

      setState(() {
        print("before _keyboardHeight: $_keyboardHeight");
        _keyboardHeight = _focusNode.hasFocus
            ? MediaQuery.of(context).viewInsets.bottom + 8.0
            : 0.0;
        print("after _keyboardHeight: $_keyboardHeight");
      });
    });*/
  }

  @override
  void dispose() {
    super.dispose();
  }

  //const Chat({super.key});
  List<Tuple2<String, bool>> messages = [];

/*
  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }


  void showKeyboard() {
    _focusNode.requestFocus();
  }

  void dismissKeyboard() {
    _focusNode.unfocus();
  }*/

  void _startNewMessage(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (btx) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: 350,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Enter your message',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          );
        });
  }

/*
  Future<void> _onDone() async {
    print('Done button clicked!');
    setState(() {
      messages.add(Tuple2(_textEditingController.text, true));
      _listLength.value += 1;
      scrollDown();
    });
    var httpReq = HttpRquest();
    var response =
        await httpReq.sendRequestToOpenAI(_textEditingController.text);
    _textEditingController.clear();
    setState(() {
      messages.add(Tuple2(response, false));
      _listLength.value += 1;
      scrollDown();
    });
    _saveList(messages);
    print("response:$response");
  }*/

  String removeNewLineAtStart(String text) {
    if (text.isNotEmpty && text.startsWith('\n')) {
      return text.substring(1);
    }
    return text;
  }

  Future<void> _onDone() async {
    print('Done button clicked!');
    setState(() {
      messages.add(Tuple2(_textEditingController.text, true));
      _listLength.value += 1;
    });

    // Wait for the ListView to be updated before scrolling down
    await Future.delayed(Duration(milliseconds: 100));
    scrollDown();

    var httpReq = HttpRquest();
    var response =
        await httpReq.sendRequestToOpenAI(_textEditingController.text);

    // Remove the new line character at the start of the response if present
    response = removeNewLineAtStart(response);
    _textEditingController.clear();
    setState(() {
      messages.add(Tuple2(response, false));
      _listLength.value += 1;
    });

    // Wait for the ListView to be updated before scrolling down
    await Future.delayed(Duration(milliseconds: 100));
    scrollDown();

    _saveList(messages);
    print("response:$response");
  }

  Future<void> _loadList() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('myList');
    print("loadList:$json");

    if (json != null) {
      print("json != null");

      final data = jsonDecode(json);
      print("data:$data");

      if (json != null) {
        final data = jsonDecode(json);
        List<dynamic> items = data;
        var messagesToLoad = <Tuple2<String, bool>>[];
        for (var item in items) {
          messagesToLoad.add(
              Tuple2(removeNewLineAtStart(item['value1']), item['value2']));
        }
        print("messagesToLoad:$messagesToLoad");
        setState(() {
          messages = messagesToLoad;
        });
      }
    } else {
      print("****");
    }
    print("*** messages:$messages");
  }

  Future<void> _saveList(List<Tuple2<String, bool>> list) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      list.map((item) => {'value1': item.item1, 'value2': item.item2}).toList(),
    );
    print("saveList:$json");
    await prefs.setString('myList', json);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPTmsg',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ChatGPT'),
        ),
        resizeToAvoidBottomInset:
            false, // remove white space on top of keyboard
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: ValueListenableBuilder<int>(
                  valueListenable: _listLength,
                  builder: (BuildContext context, int length, _) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MessageBubble(
                          message: messages[index].item1,
                          isMe: messages[index].item2,
                          messages: messages, // alternate bubble alignment
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: TextField(
                onSubmitted: (_) {
                  if (_textEditingController.text != "") {
                    _onDone();
                  }
                },
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      _textEditingController.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  hintText: 'message',
                  contentPadding: EdgeInsets.all(16.0),
                ),
              ),
            ),
          ],
        ),
        /*floatingActionButton: FloatingActionButton(
          onPressed: () {
            _listLength.value += 1;
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          child: Icon(Icons.arrow_circle_down_rounded),
        ),*/
        /*
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => {_startNewMessage(context)},
        ),*/
        /*
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => {_startNewMessage(context)},
        ),*/
      ),
    );
  }

  void scrollDown() {
    _listLength.value += 1;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void didChangeDependencies() {
    print("didChangeDependencies");
    super.didChangeDependencies();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
}
