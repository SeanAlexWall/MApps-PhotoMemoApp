class PhotoMemo {
  String docId; //firestore id
  String createdBy;
  String title;
  String memo;
  String photoFileName;
  String photoURL;
  DateTime timestamp;
  List<dynamic> sharedWith; //list of email
  List<dynamic> imageLabels; //image identifiers by ML
  int numComments;
  int numLikes;
  List<dynamic> followers;

  //Keys for firestore documents
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';
  static const NUM_COMMENTS = "numComments";
  static const NUM_LIKES = "numLikes";
  static const FOLLOWERS = "followers";
  

  PhotoMemo({
    this.docId,
    this.createdBy,
    this.title,
    this.memo,
    this.photoFileName,
    this.photoURL,
    this.timestamp,
    this.sharedWith,
    this.imageLabels,
    this.numComments,
    this.numLikes,
    this.followers,
  }) {
    this.numComments ??= 0;
    this.numLikes ??= 0;
    this.sharedWith ??= [];
    this.imageLabels ??= [];
    this.followers ??= [];
  }

  PhotoMemo.clone(PhotoMemo p){
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFileName = p.photoFileName; 
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;
    this.numComments = p.numComments;
    this.numLikes = p.numLikes;

    this.sharedWith = [];
    this.sharedWith.addAll(p.sharedWith);

    this.imageLabels = [];
    this.imageLabels.addAll(p.imageLabels);

    this.followers = [];
    this.followers.addAll(p.followers);
  }

  void assign(PhotoMemo p){
    this.docId = p.docId;
    this.createdBy = p.createdBy;
    this.title = p.title;
    this.memo = p.memo;
    this.photoFileName = p.photoFileName; 
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;
    this.numComments = p.numComments;
    this.numLikes = p.numLikes;

    this.sharedWith = [];
    this.sharedWith.addAll(p.sharedWith);

    this.imageLabels = [];
    this.imageLabels.addAll(p.imageLabels);

    this.followers = [];
    this.followers.addAll(p.followers);
  }

  Map<String, dynamic> serialize(){
    return <String, dynamic>{
      TITLE : this.title,
      MEMO : this.memo,
      CREATED_BY : this.createdBy,
      PHOTO_URL : this.photoURL,
      PHOTO_FILENAME : this.photoFileName,
      TIMESTAMP : this.timestamp,
      SHARED_WITH : this.sharedWith,
      IMAGE_LABELS : this.imageLabels,
      NUM_COMMENTS : this.numComments,
      NUM_LIKES : this.numLikes,
      FOLLOWERS: this.followers,
    };
  }

  static PhotoMemo deserialize(Map<String, dynamic> doc, String docId){
    doc[NUM_COMMENTS] ??= 0;
    return PhotoMemo(
      docId: docId,
      createdBy: doc[CREATED_BY],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFileName: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      timestamp: (doc[TIMESTAMP] == null)? null : 
        DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
      sharedWith: doc[SHARED_WITH],
      imageLabels: doc[IMAGE_LABELS],
      numComments: doc[NUM_COMMENTS],
      numLikes: doc[NUM_LIKES],
      followers: doc[FOLLOWERS],
    );
  }

  static String validateTitle(String value){
    if(value == null || value.length < 3) return 'too short';
    else return null;
  }

  static String validateMemo(String value){
    if(value == null || value.length < 5) return 'too short';
    else return null;
  }

  static String validateSharedWith(String value) {
    if(value == null || value.trim().length == 0) return null;

    List<String> emailList = value.split(RegExp('(,| )+'))
      .map((e)=> e.trim()).toList();

    for(String email in emailList){
      if (!(email.contains('@') && email.contains('.'))) 
        return 'Comma(,) or space separated email list';
    }

    return null;
  }

}