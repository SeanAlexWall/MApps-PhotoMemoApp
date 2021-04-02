import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextThemes {
  static TextStyle alert1(BuildContext context) {
    return Theme.of(context).textTheme.subtitle1.copyWith(color: Colors.red);
  }
}