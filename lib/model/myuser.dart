class MyUser {
  String photoURL;
  String displayName;
  String email;
  String uid;
  String docId;
  String appColor;
  bool darkMode = false;
  List<dynamic> followers;
  bool isAdmin = false;
  DateTime unbanDate;

  MyUser(this.uid, this.email){
    this.followers = [];
    unbanDate = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  }

  static const UID = "uid";
  static const DISPLAY_NAME = "displayName";
  static const PHOTO_URL = "photoURL";
  static const DOC_ID = "docId";
  static const COLOR = "color";
  static const DARK_MODE = "darkMode";
  static const FOLLOWERS = "followers";
  static const EMAIL = "email";
  static const IS_ADMIN = "isAdmin";
  static const UNBAN_DATE = "unbanDate";
  

  static MyUser deserialize(Map doc, String docId){
    MyUser deserializedUser = MyUser(doc[UID], doc[EMAIL]);
    deserializedUser.photoURL = doc[PHOTO_URL];
    deserializedUser.displayName = doc[DISPLAY_NAME];
    deserializedUser.docId = docId;    
    deserializedUser.appColor = doc[COLOR];
    deserializedUser.darkMode = doc[DARK_MODE];
    deserializedUser.followers = doc[FOLLOWERS];
    deserializedUser.isAdmin = doc[IS_ADMIN];
    deserializedUser.unbanDate = (doc[UNBAN_DATE] == null)? null : 
      DateTime.fromMillisecondsSinceEpoch(doc[UNBAN_DATE].millisecondsSinceEpoch);
    return deserializedUser;
  }

  Map<String, dynamic> serialize(){
    return {
      UID : this.uid,
      DISPLAY_NAME : this.displayName,
      PHOTO_URL : this.photoURL,
      DOC_ID : this.docId,
      COLOR : this.appColor,
      DARK_MODE : this.darkMode,
      FOLLOWERS : this.followers,
      EMAIL : this.email,
      IS_ADMIN : this.isAdmin,
      UNBAN_DATE : this.unbanDate,
    };
  }
}