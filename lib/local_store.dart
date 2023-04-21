import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalStore extends ChangeNotifier {
  Tuple2<String, String> myFirestoreId;

  LocalStore(this.myFirestoreId);
  String get email => myFirestoreId.item1;
  String get password => myFirestoreId.item1;

  void updateFirestoreId(Tuple2<String, String> newId) {
    myFirestoreId = newId;
    notifyListeners();
  }

  Future<void> saveFirestoreId(Tuple2<String, String> keyToSave) async {
    final myTupleString = keyToSave.toString();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('firestore', myTupleString);
    updateFirestoreId(keyToSave);
    print("_saveFirestoreId keyToSave:$keyToSave");
  }

  Future<Tuple2<String, String>?> readFirestoreId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String? value = prefs.getString('firestore');
      print("_readFirestoreId myValue:$value");
      if (value != null) {
        final myTuple = tupleFromString(value);
        print("myFirestoreId:$myTuple");
        updateFirestoreId(myTuple);
        return myTuple;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Tuple2<String, String> tupleFromString(String string) {
    final parts = string.substring(1, string.length - 1).split(', ');
    final item1 = parts[0];
    final item2 = parts[1];
    return Tuple2(item1, item2);
  }

  Future<void> loginOnFirestore(
      String email, String password, Function completion) async {
    print("loginOnFirestore email:$email");
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
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //   content: Text('User $email is logged in'),
        // ));
        //Navigator.of(context).pop();
        completion(true);
      }
    } catch (e) {
      print(e);
      completion(false);
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Failed to sign in: $e'),
      // ));
    }
  }
}
