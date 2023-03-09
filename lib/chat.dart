import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:messenger_demo/http_request.dart';
import 'package:tuple/tuple.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with ChangeNotifier {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _listLength = ValueNotifier<int>(0);

  double _keyboardHeight = 0.0;

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    _focusNode.addListener(() {
      print('Listener');
    });

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
    _focusNode.dispose();
    _scrollController.dispose();
    _listLength.dispose();
    super.dispose();
  }

  //const Chat({super.key});
  final List<Tuple2<String, bool>> messages = [
    Tuple2("Hello!", true),
    Tuple2("How are you?", false),
    Tuple2("I'm good, thanks for asking. How about you?", true),
    Tuple2("I'm doing well too, thanks.", false)
  ];

  void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void showKeyboard() {
    _focusNode.requestFocus();
  }

  void dismissKeyboard() {
    _focusNode.unfocus();
  }

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
    print("response:$response");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('ChatGPT'),
        ),
        resizeToAvoidBottomInset:
            false, // remove white space on top of keyboard
        body: Stack(
          children: <Widget>[
            Container(
              child: ValueListenableBuilder<int>(
                valueListenable: _listLength,
                builder: (BuildContext context, int length, _) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return MessageBubble(
                        message: messages[index].item1,
                        isMe:
                            messages[index].item2, // alternate bubble alignment
                      );
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey[200],
                child: TextField(
                  onSubmitted: (_) {
                    _onDone();
                  },
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        //
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
            /*
              child: Column(
                children: [
                  Container(
                    color: Colors.grey[200],
                    child: TextField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            //
                            _textEditingController.clear();
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        hintText: 'message',
                        contentPadding: EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text("Send"),
                    onPressed: () async {
                      setState(() {
                        messages.add(Tuple2(_textEditingController.text, true));
                        _listLength.value += 1;
                        scrollDown();
                      });
                      var httpReq = HttpRquest();
                      var response = await httpReq
                          .sendRequestToOpenAI(_textEditingController.text);
                      _textEditingController.clear();
                      setState(() {
                        messages.add(Tuple2(response, false));
                        _listLength.value += 1;
                        scrollDown();
                      });
                      print("response:$response");
                    },
                  ),
                ],
              ),*/
            //),
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
      duration: Duration(milliseconds: 500),
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

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isMe ? Colors.blue : Colors.grey.shade200,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
