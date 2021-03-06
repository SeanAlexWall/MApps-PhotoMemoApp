import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/comment.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget{
  static const routeName = "/commentsScreen";
  @override
  State<StatefulWidget> createState() {
    return CommentsState();
  }
}

class CommentsState extends State<CommentsScreen>{
  _Controller con;
  User user;
  PhotoMemo onePhotoMemo;
  List<Comment> commentList;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> replyFormKey = GlobalKey<FormState>();

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
    onePhotoMemo ??= args[Constant.ARG_ONE_PHOTOMEMO];
    commentList ??= args[Constant.ARG_COMMENTLIST];

    return Scaffold(
      appBar: AppBar(title: Text(onePhotoMemo.title)),
      body: Form(
        key: formKey,
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: (commentList.length == 0)? 
                  Text(
                    "No comments - yet!",
                    style: Theme.of(context).textTheme.headline5,
                  )
                  : ListView.builder(
                    itemCount: commentList.length,
                    itemBuilder: 
                    (BuildContext context, int index) => Container(
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          commentList[index].comment,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [ 
                            Text("${commentList[index].postedBy}"),
                            Text("Updated At ${commentList[index].timestamp}"),
                            Row(
                              children: [
                                RaisedButton(
                                  child: (con.replyIndex != null && con.replyIndex == index)? 
                                    Text("cancel")
                                    : Text("reply"),
                                  onPressed: () => con.setReplyIndex(index)
                                ),
                                //if the comment was posted by the current user
                                (commentList[index].postedBy == user.email)?
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => con.deleteComment(index),
                                )
                                :SizedBox(width: 1),
                                //if the comment was posted by the current user
                                (commentList[index].postedBy == user.email)?
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => con.editComment(index),
                                )
                                :SizedBox(width: 1),
                              ],
                            ),
                            (con.editIndex != null && con.editIndex == index)?
                            Form(
                              key: editFormKey,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: TextFormField(
                                      enabled: true,
                                      style: Theme.of(context).textTheme.bodyText2,
                                      decoration: InputDecoration(
                                        hintText: "Edit Comment",
                                      ),
                                      initialValue: commentList[index].comment,
                                      autocorrect: true,
                                      validator: con.validateUpdateComment,
                                      onSaved: con.saveUpdateComment,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FlatButton(
                                      color: Colors.green,
                                      child: Icon(Icons.send),
                                      onPressed: () => con.updateComment(index),
                                    ),
                                  )
                                ],
                              ),
                            )
                            :SizedBox(height: 1.0),
                            (con.replyIndex != null && con.replyIndex == index)?
                            Form(
                              key: replyFormKey,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: TextFormField(
                                      enabled: true,
                                      style: Theme.of(context).textTheme.bodyText2,
                                      decoration: InputDecoration(
                                        hintText: "Reply to Comment",
                                      ),
                                      autocorrect: true,
                                      validator: con.validateReplyComment,
                                      onSaved: con.saveReplyComment,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: FlatButton(
                                      color: Colors.green,
                                      child: Icon(Icons.send),
                                      onPressed: () => con.replyComment(index),
                                    ),
                                  )
                                ],
                              ),
                            )
                            :SizedBox(height: 1.0),
                          ],
                        ),
                        onTap: null,
                        onLongPress: null,
                      ),
                    ),
                  ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  children: [ 
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        enabled: true,
                          style: Theme.of(context).textTheme.bodyText2,
                          decoration: InputDecoration(
                            hintText: "Post a comment!",
                          ),
                          autocorrect: true,
                          validator: con.validateComment,
                          onSaved: con.saveComment,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: FlatButton(
                        color: Colors.green,
                        child: Icon(Icons.send),
                        onPressed: con.postComment,
                      ),
                    ),
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  CommentsState state;
  Comment tempComment = Comment();
  Comment tempReplyComment = Comment();
  int editIndex;
  int replyIndex;

  _Controller(this.state);

  String validateComment(String value){
    if(value == "" && editIndex == null) return "enter comment";
    else return null;
  }

  void saveComment(String value){
    if(editIndex == null) tempComment.comment = value;
  }

  void postComment() async {
    if(!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      tempComment.postedBy = state.user.email;
      tempComment.timestamp = DateTime.now();
      tempComment.photoMemoId = state.onePhotoMemo.docId;
      
      String docId = await FirebaseController.addComment(tempComment);
      tempComment.docId = docId;
      
      Comment newComment = Comment.clone(tempComment);
      
      state.commentList.insert(0, newComment);

      try{
        state.commentList = 
          await FirebaseController.getComments(state.onePhotoMemo.docId);
        try{
          if(state.onePhotoMemo.numComments == null) 
            state.onePhotoMemo.numComments = 1;
          else
            state.onePhotoMemo.numComments++;
          await FirebaseController.updatePhotoMemo(
            state.onePhotoMemo.docId, 
            {PhotoMemo.NUM_COMMENTS : state.onePhotoMemo.numComments,}
          );
          MyDialog.circularProgressStop(state.context);
        } catch (e){
          MyDialog.info(
            context: state.context,
            title: "Update PhotoMemo in Add Comment error",
            content: "$e",
          );
          MyDialog.circularProgressStop(state.context);
        }
      }catch (e){
        MyDialog.circularProgressStop(state.context);
        print("$e");
        MyDialog.info(
          context: state.context, 
          title: "getComments error", 
          content: "$e",
        );
      }

      state.formKey.currentState.reset();
      state.render((){
        
      }); //to refresh the screen
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      print("$e");
      MyDialog.info(
        context: state.context,
        title: "post comment error",
        content: "$e",
      );
    }
  }

  void deleteComment(int index) async{
    bool confirm = await MyDialog.confirm(
      context: state.context, 
      title: "Delete Comment?", 
      content: "Are you sure you want to delete this comment?", 
      cancelText: "cancel", 
      confirmText: "delete"
    );
    if(confirm){
      MyDialog.circularProgressStart(state.context);
      try {
        await FirebaseController.deleteComment(state.commentList[index]);
        try{
          if(state.onePhotoMemo.numComments == null || state.onePhotoMemo.numComments < 1) 
            throw Exception("numComments is null or less than 1 when trying to delete a comment");
          else
            state.onePhotoMemo.numComments--;
          await FirebaseController.updatePhotoMemo(
            state.onePhotoMemo.docId, 
            {PhotoMemo.NUM_COMMENTS : state.onePhotoMemo.numComments,}
          );
          MyDialog.circularProgressStop(state.context);
        } catch (e){
          MyDialog.info(
            context: state.context,
            title: "Update PhotoMemo in Delete Comment error",
            content: "$e",
          );
          MyDialog.circularProgressStop(state.context);
        }
        state.render((){
          state.commentList.removeAt(index);
        });
        MyDialog.circularProgressStop(state.context);
      }  catch (e) {
        MyDialog.circularProgressStop(state.context);
        MyDialog.info(
          context: state.context, 
          title: "Delete Comment Error", 
          content: "$e",
        );
      }
    }
  }

  void editComment(int index){
    if(editIndex == null){
      state.render(() => {editIndex = index} );
    }
    else if(editIndex == index){
      state.render(() => {editIndex = null} );
    }
  }

  String validateUpdateComment(String value){
    if(value == "" && editIndex != null) return "enter comment";
    else return null;
  }

  void saveUpdateComment(String value){
    if(editIndex != null) tempComment.comment = value;
  }

  void updateComment(int index) async {
    if(!state.editFormKey.currentState.validate()) return;
    state.editFormKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      tempComment.timestamp = DateTime.now();
      
      Map<String, dynamic> updatedInfo = {
        Comment.COMMENT : tempComment.comment,
        Comment.TIMESTAMP : tempComment.timestamp,
      };

      await FirebaseController.updateComment(
        state.onePhotoMemo.docId,
        state.commentList[index].docId,
        updatedInfo,
        );
      
      try{
        state.commentList = 
          await FirebaseController.getComments(state.onePhotoMemo.docId);
        MyDialog.circularProgressStop(state.context);
      }catch (e){
        MyDialog.circularProgressStop(state.context);
        print("$e");
        MyDialog.info(
          context: state.context, 
          title: "getComments error", 
          content: "$e",
        );
      }

      state.editFormKey.currentState.reset();
      state.render((){
        editIndex = null;
      }); //to refresh the screen
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      print("$e");
      MyDialog.info(
        context: state.context,
        title: "update  comment error",
        content: "$e",
      );
    }
  }

  void setReplyIndex(int index){
    if(replyIndex == null){
      state.render(() => {replyIndex = index} );
    }
    else if(replyIndex == index){
      state.render(() => {replyIndex = null} );
    }
  }

  String validateReplyComment(String value){
    if(value == "" && replyIndex != null) return "enter comment";
    else return null;
  }

  void saveReplyComment(String value){
    if(replyIndex != null) tempReplyComment.comment 
      = "@" + state.commentList[replyIndex].postedBy + " " + value;
  }

  void replyComment(int index) async{
    if(!state.replyFormKey.currentState.validate()) return;
    state.replyFormKey.currentState.save();

    MyDialog.circularProgressStart(state.context);

    try {
      tempReplyComment.postedBy = state.user.email;
      tempReplyComment.timestamp = DateTime.now();
      tempReplyComment.photoMemoId = state.onePhotoMemo.docId;
      
      String docId = await FirebaseController.addComment(tempReplyComment);
      tempReplyComment.docId = docId;
      
      Comment newComment = Comment.clone(tempReplyComment);
      
      state.commentList.insert(0, newComment);

      try{
        state.commentList = 
          await FirebaseController.getComments(state.onePhotoMemo.docId);
        try{
          if(state.onePhotoMemo.numComments == null) 
            state.onePhotoMemo.numComments = 1;
          else
            state.onePhotoMemo.numComments++;
          await FirebaseController.updatePhotoMemo(
            state.onePhotoMemo.docId, 
            {PhotoMemo.NUM_COMMENTS : state.onePhotoMemo.numComments,}
          );
          MyDialog.circularProgressStop(state.context);
        } catch (e){
          MyDialog.info(
            context: state.context,
            title: "Update PhotoMemo in Add Comment error",
            content: "$e",
          );
          MyDialog.circularProgressStop(state.context);
        }
      }catch (e){
        MyDialog.circularProgressStop(state.context);
        print("$e");
        MyDialog.info(
          context: state.context, 
          title: "getComments error", 
          content: "$e",
        );
      }
      state.replyFormKey.currentState.reset();
      state.render((){
        replyIndex = null;
      }); //to refresh the screen
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      print("$e");
      MyDialog.info(
        context: state.context,
        title: "post comment error",
        content: "$e",
      );
    }
  }
}