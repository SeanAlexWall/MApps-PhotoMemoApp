import 'dart:io';

import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'myview/conifg.dart';


class ProfileScreen extends StatefulWidget{
  static const routeName = "/profileScreen";
  @override
  State<StatefulWidget> createState() {
    return ProfileState();
  }

}

class ProfileState extends State<ProfileScreen>{
  _Controller con;
  User user;
  MyUser userProfile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool editMode = false;
  Map<String, dynamic> updatedInfo;
  String progressMessage;

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
    updatedInfo ??= {};
  

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Screen"),
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
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height *.4,
                  child: Stack(
                    children: [
                      con.photoFile == null?
                        userProfile.photoURL == null?
                          Icon(
                            Icons.person,
                            size: MediaQuery.of(context).size.height *.4,
                          )
                          : MyImage.network(
                            url: userProfile.photoURL,
                            context: context,
                          )
                        : Image.file(con.photoFile, fit: BoxFit.fill),
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
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Display Name: ",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        enabled: editMode,
                        style: Theme.of(context).textTheme.headline6,
                        decoration: InputDecoration(
                          hintText: "Enter Display Name",
                        ),
                        initialValue: 
                          userProfile.displayName == null? user.email : userProfile.displayName,
                        autocorrect: true,
                        validator: con.validateDisplayName,
                        onSaved: con.saveDisplayName,
                      ),
                    ),
                  ],
                ),
                Text(
                  "If not set, email will be the display name",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(height: 5.0),
                DropdownButton<Color>(
                  value: currentTheme.color,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  onChanged: editMode? con.setColor : null,
                  items: <Color>[
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                  ].map<DropdownMenuItem<Color>>((Color value){
                    return DropdownMenuItem<Color>(
                      value: value,
                      child: Icon(
                        Icons.brightness_1,
                        color: value,
                      ),
                    );
                  }).toList(),
                ),
                Switch(
                  value: currentTheme.darkMode,
                  onChanged: editMode? con.switchBrightness : null,
                ),
              ],
            )
          ),
        )
      ),
    );
  }

}

class _Controller {
  ProfileState state;
  File photoFile;
  bool colorUpdated;
  _Controller(this.state){colorUpdated = false;}

  void edit(){
    state.render((){
      state.editMode = true;
    });
  }

  void update() async {
    if(!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    MyDialog.circularProgressStart(state.context);
    try{
      //if a new photo has been selected
      if(photoFile != null){
        Map photoInfo = await FirebaseController.uploadPhotoFile(
          photo: photoFile,
          uid: state.user.uid,
          listener: (double message){
            state.render((){
              if (message == null) state.progressMessage = null;
              else {
                message *= 100;
                state.progressMessage = "Photo Uploading: ${message.toStringAsFixed(1)}%";
              }
            });
          }
        );
        state.updatedInfo[Constant.ARG_PHOTO_URL] = photoInfo[Constant.ARG_DOWNLOADURL]; 
        state.userProfile.photoURL = state.updatedInfo[Constant.ARG_PHOTO_URL];
      }
      // print("++++++++++++++++++Line 224");
      // print(colorUpdated);
      // if(colorUpdated){
      //   state.userProfile.colorMap = {
      //     100: state.userProfile.appColor[100],
      //     200: state.userProfile.appColor[200],
      //     300: state.userProfile.appColor[300],
      //     400: state.userProfile.appColor[400],
      //     500: state.userProfile.appColor[500],
      //     600: state.userProfile.appColor[600],
      //     700: state.userProfile.appColor[700],
      //     800: state.userProfile.appColor[800],
      //     900: state.userProfile.appColor[900],
      //   };
      //   print("++++++++++++++++++Line 241");
      //   //We can later use the int value and the color map to recreate the MaterialColor
      //   state.updatedInfo[MyUser.COLOR_MAP] = state.userProfile.colorMap;
      //   colorUpdated = false;
      // }
      // print("++++++++++++++++++Line 244");
      //if there is info to be updated
      if (state.updatedInfo.isNotEmpty) {
        try{
          print("Line 249 ============== ${state.updatedInfo}");
          await FirebaseController.updateUserProfile(state.userProfile.docId, state.updatedInfo);
        } catch(e){
          MyDialog.circularProgressStop(state.context);
          MyDialog.info(
            context: state.context, 
            title: "Update User Error", 
            content: "$e",
          );
        }
      }
      MyDialog.circularProgressStop(state.context);
      state.render((){
        state.editMode = false;
        print(state.editMode);
      });
    }catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context, 
        title: "Upload Photo Error", 
        content: "$e",
      );
    }
  }

  String validateDisplayName(String value){
    if(value.length < 6) 
      return "Too short. Display Name must have at least 6 characters";
    return null;
  }
  
  void saveDisplayName(String value){
    if(value != state.userProfile.displayName)
      state.updatedInfo[Constant.ARG_DISPLAY_NAME] = value;
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
  
  void switchBrightness(bool value){
    // state.updatedInfo[MyUser.DARK_MODE] = value;
    currentTheme.switchBrightness();
    state.render((){});
  }

  void setColor(Color value){
    // colorUpdated = true;
    // print(colorUpdated);
    // state.userProfile.appColor = value;
    // state.updatedInfo[MyUser.COLOR_VALUE] = value.value;
    currentTheme.setColor(value);
    state.render((){});
  }
  
}