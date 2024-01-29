import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String text) => Fluttertoast.showToast(
      msg: text,
      fontSize: 13.0,
      backgroundColor: Colors.deepPurpleAccent,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
