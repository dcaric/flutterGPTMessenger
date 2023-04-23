import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './local_store.dart';

/*
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
*/

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Tuple2<String, String>? _myFirestoreId;
  LocalStore myFirestoreId = LocalStore(const Tuple2("", ""));
  bool showLogin = false;

  Future<void> _loginOnFirestore(String email, String password) async {
    try {
      final user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      ))
          .user;
      if (user != null) {
        print("USER:$user");
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

  Future<void> saveApiKey(String apiKey) async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Save the API key to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({'apiKey': apiKey});
    } else {
      // Handle user not signed in
    }
  }

  Future<String?> readApiKey() async {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Read the API key from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      return data?['apiKey'] as String?;
    } else {
      // Handle user not signed in
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    myFirestoreId.readFirestoreId().then((Tuple2<String, String>? firestoreid) {
      if (firestoreid != null) {
        print("*** firestoreid:$firestoreid");

        myFirestoreId.loginOnFirestore(
            firestoreid.item1, firestoreid.item2, completion);
      } else {
        setState(() {
          showLogin = true;
        });
      }
      print("*** LOG IN *** showLogin:$showLogin ");
      print("Read from Firestore:$readApiKey");
    });
  }

  void completion(bool userLogged) {
    if (userLogged) {
      setState(() {
        showLogin = false;
      });
      print("show ScaffoldMessenger");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User ${myFirestoreId.email} is logged in'),
      ));
    } else {
      setState(() {
        showLogin = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User is not logged in'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 98, 73, 9),

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
                visible: showLogin,
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
                visible: showLogin,
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
                visible: showLogin,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 98, 73, 9)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: Text("Sign In"),
                  onPressed: () async {
                    String myPassw = "";
                    var user;
                    try {
                      print("******* TRYE TO LOG IN *******");
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      user = userCredential.user;
                      setState(() {
                        showLogin = false;
                      });
                      // save locally email and password
                      myFirestoreId.saveFirestoreId(Tuple2(
                          _emailController.text.trim(),
                          _passwordController.text.trim()));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'User ${_emailController.text.trim()} is logged in'),
                      ));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        try {
                          print("******* TRYE TO CREATE ACCOUNT *******");

                          user = (await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ))
                              .user;
                          print("After sign in user: $user");
                          setState(() {
                            showLogin = false;
                          });
                          // save locally email and password
                          myFirestoreId.saveFirestoreId(Tuple2(
                              _emailController.text.trim(),
                              _passwordController.text.trim()));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'User ${_emailController.text.trim()} is logged in'),
                          ));
                        } catch (e) {
                          print(e);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to sign up: $e'),
                          ));
                        }

                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      } else if (e.code == 'invalid-email') {
                        print('The email address is not valid.');
                      } else {
                        print('An error occurred: ${e.message}');
                      }
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
