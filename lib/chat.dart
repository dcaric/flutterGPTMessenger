//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:GPTmsg/http_request.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './popup.dart';
import 'package:flutter/services.dart';
import './message_buble.dart';

class Chat extends StatefulWidget {
  final String chatName;
  const Chat({Key? key, required this.chatName}) : super(key: key);

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
    _loadList();
    print("Chat name: ${widget.chatName}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  //const Chat({super.key});
  List<Tuple2<String, bool>> messages = [];

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
                decoration: const InputDecoration(
                  hintText: 'Enter your message',
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          );
        });
  }

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
    final json = prefs.getString(widget.chatName);
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
    await prefs.setString(widget.chatName, json);
  }

  String truncateString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength) + '...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPTmsg',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(truncateString(widget.chatName, 10)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        resizeToAvoidBottomInset:
            false, // remove white space on top of keyboard
        body: SafeArea(
          child: Stack(
            children: [
              Column(
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
                                messages:
                                    messages, // alternate bubble alignment
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
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
                ),
              ),
            ],
          ),
        ),
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
