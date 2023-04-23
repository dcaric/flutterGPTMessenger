import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import './popup.dart';
import 'package:flutter/services.dart';

class ContextMenu extends StatefulWidget {
  final String message;
  final bool isMe;
  List<Tuple2<String, bool>> messages;

  ContextMenu(
      {required this.message, required this.isMe, required this.messages});

  @override
  State<ContextMenu> createState() => _ContextMenuState();
}

class _ContextMenuState extends State<ContextMenu> {
  final PopupMenuExample _popup = const PopupMenuExample();

  Offset _tapPosition = Offset.zero;

  void _showContextMenu(BuildContext context) async {
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();

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
    // TODO: implement build
    throw UnimplementedError();
  }
}
