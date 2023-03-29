import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyNotifier extends ChangeNotifier {
  Tuple2<String, String> myFirestoreId;

  MyNotifier(this.myFirestoreId);

  String get email => myFirestoreId.item1;
  String get password => myFirestoreId.item1;

  void updateFirestoreId(Tuple2<String, String> newId) {
    myFirestoreId = newId;
    notifyListeners();
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Tuple2<String, String>? _myFirestoreId;
  MyNotifier myFirestoreId = MyNotifier(const Tuple2("", ""));

  Future<void> _saveFirestoreId(Tuple2<String, String> keyToSave) async {
    final myTupleString = keyToSave.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firestore', myTupleString);
    setState(() {
      _myFirestoreId = keyToSave;
      myFirestoreId.updateFirestoreId(keyToSave);
      print("_saveFirestoreId myFirestoreId:$_myFirestoreId");
    });
  }

  Future<void> _readFirestoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString('firestore');
    print("_readFirestoreId myValue:$value");
    if (value != null) {
      final myTuple = tupleFromString(value!);
      setState(() {
        _myFirestoreId = myTuple;
        print("myFirestoreId:$_myFirestoreId");
        if (_myFirestoreId != null) {
          _loginOnFirestore(_myFirestoreId!.item1, _myFirestoreId!.item2);
          myFirestoreId.updateFirestoreId(_myFirestoreId!);
        }
      });
    }
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
        // ignore: unnecessary_null_comparison
        title: myFirestoreId.email != ""
            ? const Text('User is logged in')
            : const Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: myFirestoreId.email == "" ? true : false,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
              ),
              Visibility(
                visible: myFirestoreId.email == "" ? true : false,
                child: TextFormField(
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
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: myFirestoreId.email == "" ? true : false,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text("Sign In"),
                  onPressed: () async {
                    String myPassw = "";
                    try {
                      var user;
                      if (myFirestoreId.email != "") {
                        user = (await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ))
                            .user;
                      } else {
                        user = (await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        ))
                            .user;
                        print("After sign in user: $user");
                      }

                      if (user != null) {
                        // Navigator.of(context).pop();
                        Tuple2<String, String>? myTuple = Tuple2(
                            user.email.toString(),
                            _passwordController.text.trim());
                        _saveFirestoreId(myTuple);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('User is logged in'),
                        ));
                      }
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Failed to sign up: $e'),
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
