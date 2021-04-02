import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/comment.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/comments_screen.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
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
                RaisedButton(
                  child: Text("Comments"),
                  onPressed: () => con.comments(index),
                ),
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

    void comments(int index) async {
    MyDialog.circularProgressStart(state.context);
    try{
      List<Comment> commentList = 
        await FirebaseController.getComments(state.photoMemoList[index].docId);
      MyDialog.circularProgressStop(state.context);
      Navigator.of(state.context).pushNamed(
        CommentsScreen.routeName,
        arguments: {
          Constant.ARG_USER : state.user,
          Constant.ARG_ONE_PHOTOMEMO : state.photoMemoList[index],
          Constant.ARG_COMMENTLIST : commentList,
        },
      );
    }catch (e){
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context, 
        title: "getComments error", 
        content: "$e",
      );
    }  
  }//comments
}