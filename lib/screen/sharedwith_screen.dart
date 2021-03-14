import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SharedWithScreen extends StatefulWidget{
  static const routeName = "/sharedWithScreen";
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }

}

class _SharedWithState extends State<SharedWithScreen>{
  _Controller con;
  User user;
  List<PhotoMemo> photoMemoList;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(Function fn){
    setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    return Scaffold(
      appBar: AppBar(title: Text("Shared With Me")),
      body: photoMemoList.length == 0?
        Text("No PhotoMemos Shared with me")
        : ListView.builder(
          itemCount: photoMemoList.length,
          itemBuilder: (context, index) => Card(
            elevation: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: MyImage.network(
                      url: photoMemoList[index].photoURL,
                      context: context,
                    ),
                  ),
                ),
                Text(
                 'Title: ${photoMemoList[index].title}',
                 style: Theme.of(context).textTheme.headline6, 
                ),
                Text('Memo: ${photoMemoList[index].memo}'),
                Text('Created By: ${photoMemoList[index].createdBy}'),
                Text('Created By: ${photoMemoList[index].sharedWith}'),
              ],
            ),
          ),
        ),
    );
  }

}

class _Controller {
  _SharedWithState state;

  _Controller(this.state);
}