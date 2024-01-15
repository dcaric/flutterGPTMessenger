import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

const lastNMessagesToread = 30;

class HttpRquest extends StatelessWidget {
  String? myKey;

  Future<String?> _readKey() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? value = prefs.getString('myKey');
    String? value = await SharedPreferencesHelper.readKey();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  Future<List<Tuple2<String, bool>>?> _loadList(String chatName) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(chatName);
    print("loadList:$json");

    if (json != null) {
      print("json != null");

      final data = jsonDecode(json);
      print("data:$data");

      List<dynamic> items = data;
      var messagesToLoad = <Tuple2<String, bool>>[];
      for (var item in items) {
        messagesToLoad.add(Tuple2(item['value1'], item['value2']));
      }
      print("messagesToLoad:$messagesToLoad");
      return messagesToLoad;
    } else {
      print("****");
    }
    return null;
  }

  Future<String> sendRequestToOpenAI(String question, String chatName) async {
    String? myKey = await _readKey();
    print("*** myKey: $myKey");
    print("*** question: $question");

    // read last 5 conversations
    List<Tuple2<String, bool>>? messagesToLoad = await _loadList(chatName);
    print("*** messagesToLoad: $messagesToLoad");

    String wholeQuestion = "";
    if (messagesToLoad != null && messagesToLoad.length > lastNMessagesToread) {
      print("*** messagesToLoad.length: ${messagesToLoad.length}");

      List<Tuple2<String, bool>> lastNItems = messagesToLoad.sublist(messagesToLoad.length - lastNMessagesToread, messagesToLoad.length);
      for (var element in lastNItems) {
        print("*** element: ${element.item1}");

        wholeQuestion = "$wholeQuestion > ${element.item1}";
      }
    } else if (messagesToLoad != null && messagesToLoad.length <= lastNMessagesToread) {
      for (var element in messagesToLoad) {
        wholeQuestion = "$wholeQuestion > ${element.item1}";
      }
      print("*** wholeQuestion: 1 $wholeQuestion");
    }
    wholeQuestion = "$wholeQuestion > $question";

    wholeQuestion = wholeQuestion.replaceAll('\n', ' ');

    print("*** wholeQuestion: $wholeQuestion");

    final openaiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $myKey',
    };
    final data = {
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': wholeQuestion}
      ],
      'max_tokens': 1000,
      'temperature': 0.7,
      'n': 1,
      'stop': 'None'
    };
    final response = await http.post(
      openaiUrl,
      headers: headers,
      body: jsonEncode(data),
    );
    print("1 response: ${response.body}");

    print("1 response.statusCode: ${response.statusCode}");

/*
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var text = jsonResponse['choices'][0]['text'];
      print("text: $text");
      //String responseBody = utf8.decode(text);
      //print("responseBody: ${responseBody}");
      return text;
    } else {
      throw Exception('Failed to send request: ${response.statusCode}');
    }*/

    if (response.statusCode == 200) {
      // Decode the response body using UTF-8
      String responseBody = utf8.decode(response.bodyBytes);
      // Parse the JSON response
      var jsonResponse = jsonDecode(responseBody);
      var text = jsonResponse["choices"][0]["message"]["content"];
      print("text: $text");
      return text;
    } else {
      throw Exception('Failed to send request: ${response.statusCode}');
    }
  }
}
