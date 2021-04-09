import 'package:flutter/material.dart';

class MyUser {
  String photoURL;
  String displayName;
  String uid;
  String docId;
  MaterialColor appColor;
  bool darkMode = false;
  int colorValue;
  Map<int, Color> colorMap;

  MyUser(this.uid){
    this.colorMap = {};
  }

  static const UID = "uid";
  static const DISPLAY_NAME = "displayName";
  static const PHOTO_URL = "photoURL";
  static const DOC_ID = "docId";
  static const COLOR = "color";
  static const DARK_MODE = "darkMode";
  static const COLOR_MAP = "colorMap";
  static const COLOR_VALUE = "colorValue";

  static MyUser deserialize(Map doc, String docId){
    print("====================================================in deserialize");
    MyUser deserializedUser = MyUser(doc[UID]);
    deserializedUser.photoURL = doc[PHOTO_URL];
    deserializedUser.displayName = doc[DISPLAY_NAME];
    deserializedUser.docId = docId;
    if(doc[COLOR_VALUE] != null){
      deserializedUser.colorMap = doc[COLOR_MAP];
      deserializedUser.appColor = MaterialColor(doc[COLOR_VALUE], deserializedUser.colorMap);
    }
    deserializedUser.darkMode = doc[DARK_MODE];
    return deserializedUser;
  }

  Map<String, dynamic> serialize(){
    print("====================================================in Serialize");
    if (this.appColor != null) {
      this.colorValue = appColor.value;
      this.colorMap = {
        100: this.appColor[100],
        200: this.appColor[200],
        300: this.appColor[300],
        400: this.appColor[400],
        500: this.appColor[500],
        600: this.appColor[600],
        700: this.appColor[700],
        800: this.appColor[800],
        900: this.appColor[900],
      };
    }
    
    print("====================================================before return");
    return {
      UID : this.uid,
      DISPLAY_NAME : this.displayName,
      PHOTO_URL : this.photoURL,
      DOC_ID : this.docId,
      COLOR : this.appColor == null? null : this.appColor.value,
      DARK_MODE : this.darkMode,
      COLOR_MAP : this.colorMap,
    };
  }

}