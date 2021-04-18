import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/comment.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/comments_screen.dart';
import 'package:PhotoMemoApp/screen/myview/conifg.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  MyUser userProfile;
  List<PhotoMemo> photoMemoList;
  GlobalKey<FormState> shareKey = GlobalKey<FormState>();
  List<dynamic> updatedSharedWith;

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
    userProfile ??= args[Constant.ARG_USER_PROFILE];
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
                //add later switching between this and unfollow button                
                (photoMemoList[index].followers.contains(user.email))?
                RaisedButton(
                  child: Text("Unfollow ${photoMemoList[index].createdBy}"),
                  onPressed: () => con.unfollow(index),
                )
                : RaisedButton(
                  child: Text("Follow ${photoMemoList[index].createdBy}"),
                  onPressed: () => con.follow(index),
                ),
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
                Text('Shared With: ${photoMemoList[index].sharedWith}'),
                Text("Followers: ${photoMemoList[index].followers}"),
                Row(
                  children: [
                    RaisedButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble,
                          ),
                          Text(
                            " ${photoMemoList[index].numComments}",
                            //style: CustomTextThemes.alert1(context)
                          )
                        ]
                      ),
                      onPressed: () => con.comments(index),
                    ),
                    SizedBox(width: 5.0),
                    RaisedButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                          ),
                          Text(
                            photoMemoList[index].numLikes == null? 
                            " 0" : " ${photoMemoList[index].numLikes}",
                            //style: CustomTextThemes.alert1(context)
                          )
                        ]
                      ),
                      onPressed: () => con.like(index),
                    ),
                    SizedBox(width: 5.0),
                    RaisedButton(
                      child: Row(
                        children: [
                          Icon(
                            Icons.share,
                          ),
                          Text(
                            "Share",
                          )
                        ]
                      ),
                      onPressed: () => con.reshare(index),
                    ),
                  ],
                ),
                (con.shareIndex != null && con.shareIndex == index)?
                  Form(
                    key: shareKey,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            enabled: true,
                            style: Theme.of(context).textTheme.bodyText2,
                            decoration: InputDecoration(
                              hintText: "SharedWith (comma separated email list)",
                            ),
                            autocorrect: true,
                            validator: PhotoMemo.validateSharedWith,
                            onSaved: con.saveSharedWith,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: FlatButton(
                            color: Colors.green,
                            child: Icon(Icons.send),
                            onPressed: () => con.reshareMemo(index),
                          ),
                        )
                      ],
                    ),
                  )
                  :SizedBox(height: 1.0),
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

  int shareIndex;

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

  void follow(int index) async{
    try {
      MyUser posterProfile = 
        await FirebaseController.getUserProfileFromEmail(email: state.photoMemoList[index].createdBy);
      
      posterProfile.followers.add(state.user.email.trim());
      
      try {
        await FirebaseController.updateUserProfile(posterProfile.docId, {MyUser.FOLLOWERS: posterProfile.followers});
      } catch (e) {
        MyDialog.info(
          context: state.context,
          title: "UpdateUserProfile in follow Error",
          content: "$e",
        );
      }

      for (PhotoMemo photoMemo in state.photoMemoList) {
        if (photoMemo.createdBy == state.photoMemoList[index].createdBy) {
          photoMemo.followers.add(state.user.email);
          
          try{
            await FirebaseController.updatePhotoMemo(
              photoMemo.docId,
              {PhotoMemo.FOLLOWERS: photoMemo.followers},
            );
          } catch(e){
            MyDialog.info(
              context: state.context,
              title: "UpdatePhotoMemo in follow Error",
              content: "$e",
            );
          }
        }
      }
    } catch (e) {
      MyDialog.info(
        context: state.context, 
        title: "GetUserProfileFromEmail in follow Error", 
        content: "$e",
      );
    }
    state.render((){}); // to refresh the page
  }

  void unfollow(int index) async{
    try {
      MyUser posterProfile = 
        await FirebaseController.getUserProfileFromEmail(email: state.photoMemoList[index].createdBy);
      
      posterProfile.followers.removeWhere((element) => element == state.user.email.trim());
      
      try {
        await FirebaseController.updateUserProfile(posterProfile.docId, {MyUser.FOLLOWERS: posterProfile.followers});
      } catch (e) {
        MyDialog.info(
          context: state.context,
          title: "UpdateUserProfile in unfollow Error",
          content: "$e",
        );
      }

      for (PhotoMemo photoMemo in state.photoMemoList) {
        if (photoMemo.createdBy == state.photoMemoList[index].createdBy) {
          photoMemo.followers.removeWhere((element) => element == state.user.email);
          
          try{
            await FirebaseController.updatePhotoMemo(
              photoMemo.docId,
              {PhotoMemo.FOLLOWERS: photoMemo.followers},
            );
          } catch(e){
            MyDialog.info(
              context: state.context,
              title: "UpdatePhotoMemo in follow Error",
              content: "$e",
            );
          }
        }
      }
    } catch (e) {
      MyDialog.info(
        context: state.context, 
        title: "GetUserProfileFromEmail in unfollow Error", 
        content: "$e",
      );
    }
    state.render((){}); // to refresh the page
  }

  void like(int index) async{
    try{
      if(state.photoMemoList[index].numLikes == null) 
        state.photoMemoList[index].numLikes = 1;
      else
        state.photoMemoList[index].numLikes++;

      
      await FirebaseController.updatePhotoMemo(
          state.photoMemoList[index].docId, 
          {PhotoMemo.NUM_LIKES : state.photoMemoList[index].numLikes,}
          );
      Fluttertoast.showToast(
        msg: "Liked!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: currentTheme.color,
        textColor: Theme.of(state.context).textTheme.bodyText1.color,
        fontSize: 16.0
      );
      state.render((){}); //to refresh the page
    } catch (e){
      MyDialog.info(
        context: state.context,
        title: "Update PhotoMemo in Like error",
        content: "$e",
      );
      MyDialog.circularProgressStop(state.context);
    }
  }

  void reshare(int index){
    print("Index: $index shareIndex: $shareIndex");
    if(shareIndex == null) state.render(() => shareIndex = index);
    else if(shareIndex == index) state.render(() => shareIndex = null);
    else return;
  }

  void saveSharedWith(String value){
    if(value.trim().length != 0){
      state.updatedSharedWith = value
        .split(RegExp('(,| )+'))
        .map((e) => e.trim())
        .toList();
    }
  }

  void reshareMemo(int index) async{
    if(!state.shareKey.currentState.validate()) return;
    
    state.shareKey.currentState.save();

    if(state.updatedSharedWith.isNotEmpty){
      for(String sharedEmail in state.updatedSharedWith){
        state.photoMemoList[index].sharedWith.add(sharedEmail);
      }
      try{
        await FirebaseController.updatePhotoMemo(
          state.photoMemoList[index].docId,
          {PhotoMemo.SHARED_WITH : state.photoMemoList[index].sharedWith});
        state.shareKey.currentState.reset();
        Fluttertoast.showToast(
          msg: "Shared!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: currentTheme.color,
          textColor: Theme.of(state.context).textTheme.bodyText1.color,
          fontSize: 16.0
        );
        state.render(() => shareIndex = null);
      }catch (e){
        MyDialog.info(
          context: state.context,
          title: "Update PhotoMemo in reshare error",
          content: "$e",
        );
      }
    }
  }
}