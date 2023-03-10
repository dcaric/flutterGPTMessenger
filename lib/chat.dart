import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:messenger_demo/http_request.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './popup.dart';
import 'package:flutter/services.dart';

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

  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final PopupMenuExample _popup = const PopupMenuExample();

  double _keyboardHeight = 0.0;

  @override
  void initState() {
    print("INITSTATE");
    super.initState();
    _focusNode.addListener(() {
      print('Listener');
    });
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
    _focusNode.dispose();
    _scrollController.dispose();
    _listLength.dispose();
    super.dispose();
  }

  //const Chat({super.key});
  List<Tuple2<String, bool>> messages = [
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
          messagesToLoad.add(Tuple2(item['value1'], item['value2']));
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
                        isMe: messages[index].item2,
                        messages: messages, // alternate bubble alignment
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

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  List<Tuple2<String, bool>> messages;

  MessageBubble(
      {required this.message, required this.isMe, required this.messages});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final PopupMenuExample _popup = const PopupMenuExample();

  Offset _tapPosition = Offset.zero;

  void _showContextMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
        context: context,

        // Show the context menu at the tap location
        /*position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),*/
        position: RelativeRect.fromLTRB(_tapPosition.dx, _tapPosition.dy - 30,
            _tapPosition.dx + 30, _tapPosition.dy),

        // set a list of choices for the context menu
        items: [
          const PopupMenuItem(
            value: 'Copy',
            child: Text('Copy'),
          ),
          const PopupMenuItem(
            value: 'Delete',
            child: Text('Delete'),
          ),
        ]);

    // Implement the logic for each choice here
    switch (result) {
      case 'Copy':
        debugPrint('copy');
        await Clipboard.setData(ClipboardData(text: widget.message));
        break;
      case 'Delete':
        debugPrint('delete');
        List<Tuple2<String, bool>> messagesNew = [];
        widget.messages.forEach((message) {
          if (message.item1 != widget.message) {
            messagesNew.add(message);
          }
          // dario to do: sate to sahred_pref
          // and trigger state update in another widget
        });
        break;
    }
  }

  void _getTapPosition(BuildContext context, TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
      print("0 _tapPosition: $_tapPosition");

      final Size size = referenceBox.size; // or _widgetKey.currentContext?.size
      print('Size: ${size.width}, ${size.height}');

      final Offset offset = referenceBox.localToGlobal(Offset.zero);
      print('Offset: ${offset.dx}, ${offset.dy}');
      print(
          'Position: ${(offset.dx + size.width)}, ${(offset.dy + size.height)}');

      Size screenSize = MediaQuery.of(context).size;
      print("screenSize.height: ${screenSize.height}");
      print("screenSize.width: ${screenSize.width}");

      if (_tapPosition.dx + 30 > screenSize.width - 30) {
        _tapPosition = Offset(screenSize.width - 30, (offset.dy + size.height));
      } else {
        _tapPosition = Offset(_tapPosition.dx, (offset.dy + size.height));
      }
      print("_tapPosition: $_tapPosition");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: widget.isMe ? Colors.blue : Colors.grey.shade200,
          ),
          child: GestureDetector(
            onTapDown: (details) => _getTapPosition(context, details),
            onLongPress: () {
              // Handle tap on the text
              print("ononLongPressTap: ${widget.message}");
              //const PopupMenuExample();
              _showContextMenu(context);
            },
            child: Text(
              widget.message,
              style: TextStyle(
                color: widget.isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          )),
    );
  }
}
