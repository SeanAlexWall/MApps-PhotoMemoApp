import 'package:flutter/material.dart';

class MyDialog {

static void circularProgressStart(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(
        strokeWidth: 10.0,
      ),
    ),
  );
}

static void circularProgressStop(BuildContext context) {
  Navigator.pop(context);
}



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
  static Future<bool> confirm({
    @required BuildContext context,
    @required String title,
    @required String content,
    @required String cancelText,
    @required String confirmText,
    }) async {
    bool response;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(
            child: Text(cancelText, style: Theme.of(context).textTheme.button,),
            onPressed: () {
              Navigator.of(context).pop();
              response = false;
            },
          ),
          RaisedButton(
            child: Text(confirmText, style: Theme.of(context).textTheme.button,),
            onPressed: () {
              Navigator.of(context).pop();
              response = true;
            },
          ),
        ],
      ),
    );
    return response;
  }
}