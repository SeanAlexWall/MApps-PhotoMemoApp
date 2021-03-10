import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = "/detailedViewScreen";

  @override
  State<StatefulWidget> createState() {
    return DetailedViewState();
  }
}

class DetailedViewState extends State<DetailedViewScreen> {
  _Controller con;
  User user;
  PhotoMemo onePhotoMemo;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn){
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    return Scaffold(
      appBar: AppBar(title: Text("Detailed View")),
      body: Text(onePhotoMemo.imageLabels.join(('|'))),
    );
  }

}

class _Controller{
  DetailedViewState state;

  _Controller(this.state);
}