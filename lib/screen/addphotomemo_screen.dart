import 'dart:io';

import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddPhotoMemoScreen extends StatefulWidget{
  static const routeName = "/addPhotoMemoScreen";

  @override
  State<StatefulWidget> createState() {
    return _AddPhotoMemoState();
  }
  
}

class _AddPhotoMemoState extends State<AddPhotoMemoScreen> {
  _Controller con;
  User user;
  MyUser userProfile;
  List<PhotoMemo> photoMemoList;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File photo;
  String progressmessage;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) {
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    userProfile ??= args[Constant.ARG_USER_PROFILE];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    return Scaffold(
      appBar: AppBar(
        title: Text("Add PhotoMemo"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.save,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height *.4,
                    child: photo == null ? 
                      Icon(Icons.photo_library, size: 250,) :
                      Image.file(photo, fit: BoxFit.fill,),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.blue[200],
                      child: PopupMenuButton<String>(
                        onSelected: con.getPhoto,
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.photo_camera),
                                Text(Constant.SOURCE_CAMERA),
                              ],
                            ),
                            value: Constant.SOURCE_CAMERA,
                          ),
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(Icons.photo_album),
                                Text(Constant.SOURCE_GALLERY),
                              ],
                            ),
                            value: Constant.SOURCE_GALLERY,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              progressmessage == null? 
                SizedBox(height: 1,) :
                Text(
                  progressmessage, 
                  style: Theme.of(context).textTheme.headline6,
                ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Title'
                ),
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Memo'
                ),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'SharedWith (comma separated email list)'
                ),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),
            ]
          )
        )
      ),
    );
  }

}

class _Controller {
  _AddPhotoMemoState state;
  PhotoMemo tempMemo = PhotoMemo();

  _Controller(this.state);

  void save() async {
    if(!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();
    
    MyDialog.circularProgressStart(state.context);

    try{
      Map photoInfo = await FirebaseController.uploadPhotoFile(
        photo: state.photo,
        uid:state.user.uid,
        listener: (double progress) {
          state.render((){
            if(progress == null) state.progressmessage = null;
            else {
              progress *= 100;
              state.progressmessage = 'Uploading: ${progress.toStringAsFixed(1)}%';
            }
          });
        },
      );

      //image labels by ML
      state.render(() => state.progressmessage = 'ML Image Labeller Running');
      List<dynamic> imageLabels = 
          await FirebaseController.getImageLabels(photoFile: state.photo);
      state.render(() => state.progressmessage = null);


      tempMemo.photoFileName = photoInfo[Constant.ARG_FILENAME];
      tempMemo.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
      tempMemo.timestamp = DateTime.now();
      tempMemo.createdBy = state.user.email;
      tempMemo.imageLabels = imageLabels;
      //shares with all followers
      for(String follower in state.userProfile.followers){
        tempMemo.sharedWith.add(follower);
      }
      //so that sharedwith can switch between follow/unfollow buttons
      for(String follower in state.userProfile.followers){
        tempMemo.followers.add(follower);
      }
      String docId = await FirebaseController.addPhotoMemo(tempMemo);
      tempMemo.docId = docId;
      state.photoMemoList.insert(0, tempMemo);

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context); //return to user home screen
    }catch (e){
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context, 
        title: "Save PhotoMemoError",
        content: "$e",
      );
      print('=======$e');
    }
  }

  void getPhoto(String source) async {
    try{
      PickedFile _imageFile;
      var _picker = ImagePicker();
      if(source == Constant.SOURCE_CAMERA){
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      } 
      else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }

      if (_imageFile == null) return;

      state.render((){
        state.photo = File(_imageFile.path);
      });
    }catch (e){
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picture',
        content: '$e',
      );
    }
  }


  void saveTitle(String value){
    tempMemo.title = value;
  }
  void saveMemo(String value){
    tempMemo.memo = value;
  }
  void saveSharedWith(String value){
    if(value.trim().length != 0){
      tempMemo.sharedWith = value.split(RegExp('(,| )+'))
      .map((e)=> e.trim()).toList();
    }
  }
}