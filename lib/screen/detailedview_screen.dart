import 'dart:io';

import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  PhotoMemo onePhotoMemoOriginal;
  PhotoMemo onePhotoMemoTemp;
  bool editMode = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String progressMessage;

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
    onePhotoMemoOriginal ??= args[Constant.ARG_ONE_PHOTOMEMO];
    onePhotoMemoTemp ??=  new PhotoMemo.clone(onePhotoMemoOriginal); 

    return Scaffold(
      appBar: AppBar(
        title: Text("Detailed View"),
        actions: [
          editMode? 
            IconButton(
              icon: Icon(Icons.check),
              onPressed: con.update,
            )
            : IconButton(
              icon: Icon(Icons.edit),
              onPressed: con.edit,
            ),
        ], 
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * .4,
                        child: con.photoFile == null?
                        MyImage.network(
                          url: onePhotoMemoTemp.photoURL, 
                          context: context
                        )
                        : Image.file(con.photoFile, fit: BoxFit.fill),
                      ),
                      editMode? Positioned(
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
                      )
                      : SizedBox(height: 1),
                    ],
                  ),
                  progressMessage == null?
                    SizedBox(height: 1):
                    Text(
                      progressMessage, 
                      style: Theme.of(context).textTheme.headline6
                    ),
                  TextFormField(
                    enabled: editMode,
                    style: Theme.of(context).textTheme.headline6,
                    decoration: InputDecoration(
                      hintText: "Enter title",
                    ),
                    initialValue: onePhotoMemoTemp.title,
                    autocorrect: true,
                    validator: PhotoMemo.validateTitle,
                    onSaved: con.saveTitle,
                  ),
                  TextFormField(
                    enabled: editMode,
                    decoration: InputDecoration(
                      hintText: "Enter Memo",
                    ),
                    initialValue: onePhotoMemoTemp.memo,
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    validator: PhotoMemo.validateMemo,
                    onSaved: con.saveMemo,
                  ),
                  TextFormField(
                    enabled: editMode,
                    decoration: InputDecoration(
                      hintText: "Enter Shared With (email list)",
                    ),
                    initialValue: onePhotoMemoTemp.sharedWith.join(","),
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    validator: PhotoMemo.validateSharedWith,
                    onSaved: con.saveSharedWith,
                  ),
                  SizedBox(height: 5.0),
                  Constant.DEV? 
                    Text(
                      'Image Labels generated by ML',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : SizedBox(height: 1),
                  Constant.DEV? 
                    Text(
                      onePhotoMemoTemp.imageLabels.join("|"),
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : SizedBox(height: 1),
                ]
              ),
            )
          ),
        ),
      ),
    );
  }

}

class _Controller{
  DetailedViewState state;
  File photoFile;


  _Controller(this.state);

  void update() async {
    if(!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    try{
      MyDialog.circularProgressStart(state.context);
      Map<String, dynamic> updateInfo = {};
      if(photoFile != null){
        Map photoInfo = await FirebaseController.uploadPhotoFile(
          photo: photoFile, 
          filename: state.onePhotoMemoTemp.photoFileName,
          uid: state.user.uid, 
          listener: (double message){
            state.render((){
              if (message == null) state.progressMessage = null;
              else {
                message *= 100;
                state.progressMessage = "Photo Uploading: ${message.toStringAsFixed(1)}%";
              }
            });
          },
        );

        state.onePhotoMemoTemp.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
        state.render(() => state.progressMessage = "ML Image Labeler Running");
        List<dynamic> labels = await FirebaseController.getImageLabels(photoFile: photoFile);
        state.onePhotoMemoTemp.imageLabels = labels;

        updateInfo[PhotoMemo.PHOTO_URL] = photoInfo[Constant.ARG_DOWNLOADURL];
        updateInfo[PhotoMemo.IMAGE_LABELS] = labels;
      }

      if(state.onePhotoMemoOriginal.title != state.onePhotoMemoTemp.title)
        updateInfo[PhotoMemo.TITLE] = state.onePhotoMemoTemp.title;
      if(state.onePhotoMemoOriginal.memo != state.onePhotoMemoTemp.memo)
        updateInfo[PhotoMemo.MEMO] = state.onePhotoMemoTemp.memo;
      if(!listEquals(state.onePhotoMemoOriginal.sharedWith, state.onePhotoMemoTemp.sharedWith))
        updateInfo[PhotoMemo.SHARED_WITH] = state.onePhotoMemoTemp.sharedWith; 

      updateInfo[PhotoMemo.TIMESTAMP] = DateTime.now();  

      await FirebaseController.updatePhotoMemo(state.onePhotoMemoOriginal.docId, updateInfo);
    
      state.onePhotoMemoOriginal.assign(state.onePhotoMemoTemp);

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context);
    }catch(e){
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context, 
        title: "Update PhotoMemo Error", 
        content: "$e",
      );
    }
  }
  void edit(){
    state.render((){
      state.editMode = true;
    });
  }

  void saveTitle(String value){
    state.onePhotoMemoTemp.title = value;
  }

  void saveMemo(String value){
    state.onePhotoMemoTemp.memo = value;
  }

  void saveSharedWith(String value){
    if(value.trim().length != 0){
      state.onePhotoMemoTemp.sharedWith = value
                                            .split(RegExp('(,| )+'))
                                            .map((e) => e.trim())
                                            .toList();
    }
  }

  void getPhoto(String source) async{
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
        photoFile = File(_imageFile.path);
      });
    }catch (e){
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picture',
        content: '$e',
      );
    }
  }
}