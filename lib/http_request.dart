import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class HttpRquest extends StatelessWidget {
  String? myKey;

  Future<String?> _readKey() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? value = prefs.getString('myKey');
    String? value = await SharedPreferencesHelper.readKey();
    print("myValue:$value");
    return value;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

  Future<List<Tuple2<String, bool>>?> _loadList() async {
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
        return messagesToLoad;
      }
    } else {
      print("****");
    }
    return null;
  }

  Future<String> sendRequestToOpenAI(String question) async {
    String? myKey = await _readKey();
    print("*** myKey: ${myKey}");
    print("*** question: ${question}");

    // read last 5 conversations
    List<Tuple2<String, bool>>? messagesToLoad = await _loadList();

    String wholeQuestion = "";
    if (messagesToLoad != null && messagesToLoad.length > 5) {
      print("*** messagesToLoad.length: ${messagesToLoad.length}");

      List<Tuple2<String, bool>> lastNItems = messagesToLoad.sublist(
          messagesToLoad.length - 5, messagesToLoad.length);
      lastNItems.forEach((element) {
        print("*** element: ${element.item1}");

        wholeQuestion = wholeQuestion + " > " + element.item1;
      });
      wholeQuestion = wholeQuestion + " > " + question;
    } else {
      wholeQuestion = question;
    }

    wholeQuestion = wholeQuestion.replaceAll('\n', ' ');

    print("*** wholeQuestion: $wholeQuestion");

    final openaiUrl = Uri.parse('https://api.openai.com/v1/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $myKey',
    };
    final data = {
      'model': 'text-davinci-003',
      'prompt': wholeQuestion,
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

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var text = jsonResponse['choices'][0]['text'];
      //print("text: $text");
      //print("response.body: ${response.body}");
      return text;
    } else {
      throw Exception('Failed to send request: ${response.statusCode}');
    }
  }
}
