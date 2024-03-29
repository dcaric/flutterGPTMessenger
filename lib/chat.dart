//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:GPTmsg/http_request.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  bool _isLoading = false;
  double fontSize = 16;

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    loadList();
    print("Chat name: ${widget.chatName}");
    _readFontSize();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _readFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? value = prefs.getDouble('fontSize');
    setState(() {
      fontSize = value ?? 16;
    });
    print("font size: $value");
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

  String removeNewLineAtStart(String text, String removeString) {
    if (text.isNotEmpty && text.startsWith(removeString)) {
      return text.substring(1);
    }
    return text;
  }

  Future<void> _onDone() async {
    print('Done button clicked!');
    setState(() {
      _isLoading = true;
      messages.add(Tuple2(_textEditingController.text, true));
      _listLength.value += 1;
    });

    // Wait for the ListView to be updated before scrolling down
    await Future.delayed(const Duration(milliseconds: 100));
    scrollDown();

    var httpReq = HttpRquest();
    var response = await httpReq.sendRequestToOpenAI(_textEditingController.text, widget.chatName);

    setState(() {
      _isLoading = false; // Set isLoading to false after receiving the response
    });

    // Remove the new line character at the start of the response if present
    response = removeNewLineAtStart(response, '\n');
    response = response.replaceAll('>', '');
    _textEditingController.clear();
    setState(() {
      messages.add(Tuple2(response, false));
      _listLength.value += 1;
    });

    // Wait for the ListView to be updated before scrolling down
    await Future.delayed(const Duration(milliseconds: 100));
    scrollDown();

    _saveList(messages);
    print("response:$response");
  }

  Future<void> loadList() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(widget.chatName);
    print("loadList:$json");

    if (json != null) {
      print("json != null");

      final data = jsonDecode(json);
      print("data:$data");

      List<dynamic> items = data;
      var messagesToLoad = <Tuple2<String, bool>>[];
      for (var item in items) {
        messagesToLoad.add(Tuple2(removeNewLineAtStart(item['value1'], '\n'), item['value2']));
      }
      print("messagesToLoad:$messagesToLoad");
      setState(() {
        messages = messagesToLoad;
      });
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
      return '${input.substring(0, maxLength)}...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPTmsg',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 98, 73, 9),
        scaffoldBackgroundColor: Color.fromARGB(255, 225, 218, 208),
      ),
      home: Scaffold(
        appBar: LoadingAppBar(
          title: truncateString(widget.chatName, 10),
          isLoading: _isLoading, // Pass the isLoading state
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        resizeToAvoidBottomInset: false, // remove white space on top of keyboard

        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 44.0,
                ),
                child: Column(
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
                                  messages: messages,
                                  chatName: widget.chatName,
                                  onDelete: (indexToDelete) {
                                    setState(() {
                                      messages.removeAt(indexToDelete);
                                      _listLength.value -= 1;
                                    });
                                    _saveList(messages);
                                    loadList();
                                  },
                                );

                                /*MessageBubble(
                                  message: messages[index].item1,
                                  isMe: messages[index].item2,
                                  messages: messages,
                                  chatName: widget
                                      .chatName, // alternate bubble alignment
                                );*/
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 0.0,
                  ),
                  child: Container(
                    color: Colors.grey[200],
                    child: TextField(
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }
}

class LoadingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isLoading;
  final VoidCallback onBackPressed;

  LoadingAppBar({
    required this.title,
    this.isLoading = false,
    required this.onBackPressed,
  });

  @override
  _LoadingAppBarState createState() => _LoadingAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _LoadingAppBarState extends State<LoadingAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: widget.isLoading
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : Text(widget.title),
      backgroundColor: Color.fromARGB(255, 98, 73, 9),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: widget.onBackPressed,
      ),
    );
  }
}
