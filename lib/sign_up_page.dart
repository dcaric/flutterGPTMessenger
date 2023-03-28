import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
      print("_saveFirestoreId myFirestoreId:$myFirestoreId");
    });
  }

  Future<void> _readFirestoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('firestore');
    final myTuple = tupleFromString(value!);
    print("myValue:$value");
    setState(() {
      myFirestoreId = myTuple;
      print("myFirestoreId:$myFirestoreId");
      if (myFirestoreId != null) {
        _loginOnFirestore(myFirestoreId!.item1, myFirestoreId!.item2);
      }
    });
  }

  Tuple2<String, String> tupleFromString(String string) {
    final parts = string.substring(1, string.length - 1).split(', ');
    final item1 = parts[0];
    final item2 = parts[1];
    return Tuple2(item1, item2);
  }

  Future<void> _loginOnFirestore(String email, String password) async {
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ))
          .user;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'email': user.email});
        print("_loginOnFirestore LOGGED IN");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User $email is logged in'),
        ));
        //Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign in: $e'),
      ));
    }
  }

  void initState() {
    super.initState();
    // perform some action when the widget is displayed
    //Tuple2<String, String>? myTuple = Tuple2("dario.caric@gmail.com", "Chatgpt23#");
    //_saveFirestoreId(myTuple);

    _readFirestoreId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
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
                    final user = (await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    ))
                        .user;
                    if (user != null) {
                      // Navigator.of(context).pop();
                    }
                  } catch (e) {
                    print(e);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to sign up: $e'),
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
