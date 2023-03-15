import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import './popup.dart';
import 'package:flutter/services.dart';
import './contextmenu.dart';

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

  String get message => widget.message;
  bool get isMe => widget.isMe;
  List<Tuple2<String, bool>> get messages => widget.messages;

  late final ContextMenu _contextmenu =
      ContextMenu(isMe: isMe, message: message, messages: messages);

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
            onTapDown: (details) => {_getTapPosition(context, details)},
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
