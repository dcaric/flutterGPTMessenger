import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  //const Chat({super.key});

  final List<String> messages = [
    "Hello!",
    "How are you?",
    "I'm good, thanks for asking. How about you?",
    "I'm doing well too, thanks."
  ];

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
        body: Container(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              return MessageBubble(
                message: messages[index],
                isMe: index % 2 == 0, // alternate bubble alignment
              );
            },
          ),
        ),
      ),
    );
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
