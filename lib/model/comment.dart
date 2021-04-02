class Comment {
  String comment;
  String postedBy;
  DateTime timestamp;
  String photoMemoId;
  String docId;
  //String superCommentId; //maybe?
  
  //Keys for firestore documents
  static const COMMENT = 'comment';
  static const POSTED_BY = 'postedBy';
  static const TIMESTAMP = 'timestamp';
  static const PHOTOMEMO_ID = 'photoMemoId';
  static const COMMENT_ID = 'commentId';

  Comment({
    this.comment,
    this.postedBy,
    this.timestamp,
    this.photoMemoId,
    this.docId,
  });

  Comment.clone(Comment c){
    this.comment = c.comment;
    this.postedBy = c.postedBy;
    this.timestamp = c.timestamp;
    this.photoMemoId = c.photoMemoId;
    this.docId = c.docId;
  }

  Map<String, dynamic> serialize(){
    return <String, dynamic>{
      COMMENT : this.comment,
      POSTED_BY : this.postedBy,
      TIMESTAMP : this.timestamp,
      PHOTOMEMO_ID : this.photoMemoId,
      //COMMENT_ID : this.commentId,
    };
  }

  static Comment deserialize(Map<String, dynamic> doc, String docId){
    return Comment(
      docId: docId,
      comment: doc[COMMENT],
      postedBy: doc[POSTED_BY],
      timestamp: (doc[TIMESTAMP] == null)? null : 
        DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
      photoMemoId: doc[PHOTOMEMO_ID],
    );
  }
}