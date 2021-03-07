import 'package:flutter/material.dart';

class MyDialog {
  static void info({
    @required BuildContext context,
    @required String title,
    @required String content,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(
            child: Text("Ok", style: Theme.of(context).textTheme.button,),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}