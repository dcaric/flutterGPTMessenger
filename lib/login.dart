import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Tuple2<String, String>? myFirestoreId;

  Future<void> _saveFirestoreId(Tuple2<String, String> keyToSave) async {
    final myTupleString = keyToSave.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firestore', myTupleString);
    setState(() {
      myFirestoreId = keyToSave;
    });
  }

  Future<void> _readFirestoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('firestore');
    final myTuple = tupleFromString(value!);
    print("myValue:$value");
    setState(() {
      myFirestoreId = myTuple;
    });
  }

  Tuple2<String, String> tupleFromString(String string) {
    final parts = string.substring(1, string.length - 1).split(', ');
    final item1 = parts[0];
    final item2 = parts[1];
    return Tuple2(item1, item2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Text("Sign In"),
                onPressed: () async {
                  try {
                    final user =
                        (await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    ))
                            .user;

                    if (user != null) {
                      print("user:$user");
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .set({'email': user.email});
                      Tuple2<String, String>? myTuple =
                          Tuple2(user.email.toString(), user.uid);
                      _saveFirestoreId(myTuple);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('User is logged in'),
                      ));
                      //Navigator.of(context).pop();
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to sign in: $e'),
                    ));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
