import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './shared_preferences_helper.dart';

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

  Future<String> sendRequestToOpenAI(String question) async {
    String? myKey = await _readKey();
    print("*** myKey: ${myKey}");
    print("*** question: ${question}");

    final openaiUrl = Uri.parse('https://api.openai.com/v1/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $myKey',
    };
    final data = {
      'model': 'text-davinci-003',
      'prompt': question,
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
