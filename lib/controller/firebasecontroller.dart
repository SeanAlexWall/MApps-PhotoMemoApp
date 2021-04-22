import 'dart:io';

import 'package:PhotoMemoApp/model/comment.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseController {
  static Future<User> signIn({@required String email, @required String password}) async{
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    );

    return userCredential.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    @required String uid,
    @required Function listener,
              String filename,
  }) async {
    filename ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if(event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL = await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL : downloadURL, 
      Constant.ARG_FILENAME : filename,
    };
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo)async{
    var ref = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .add(photoMemo.serialize());
    return ref.id;
  }

  static Future<void> updatePhotoMemo(String docId, Map<String, dynamic> updateInfo) async{
    await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(docId)
      .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoList({@required String email}) async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Constant.PHOTOMEMO_COLLECTION)
      .where(PhotoMemo.CREATED_BY, isEqualTo: email)
      .orderBy(PhotoMemo.TIMESTAMP, descending: true)
      .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc){
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<List<dynamic>> getImageLabels({@required File photoFile})  async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);
    List<dynamic> labels = <dynamic>[];
    for(ImageLabel label in cloudLabels){
      if(label. confidence >= Constant.MIN_ML_CONFIDENCE){
        labels.add(label.text.toLowerCase());
      }
    }
    return labels;
  }
  
  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );

  }

  static Future<MyUser> getUserProfile(String uid, String email) async {
    MyUser userProfile;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .where(MyUser.UID, isEqualTo: uid)
      .get();
    //there is not yet a userprofile for this uid
    if(querySnapshot.size == 0){
      userProfile = MyUser(uid, email);
      userProfile.docId = await addUserProfile(userProfile, uid);
      
    }
    else if(querySnapshot.size == 1){
      querySnapshot.docs.forEach((doc) {
        userProfile = MyUser.deserialize(doc.data(), doc.id);
      });
    }
    else throw "More than one user profile for specified uid: $uid";
    return userProfile;
  }

  static Future<String> addUserProfile(MyUser userProfile, String uid) async{
    await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .doc(uid)
      .set(userProfile.serialize());
    return uid;
  }

  static Future<void> updateUserProfile(String docId, Map<String, dynamic> updatedInfo) async{
    await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .doc(docId)
      .update(updatedInfo);

  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .where(PhotoMemo.SHARED_WITH, arrayContains: email)
      .orderBy(PhotoMemo.TIMESTAMP, descending: true)
      .get();
    List<PhotoMemo> result =  <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });
    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(p.docId)
      .delete();
    await FirebaseStorage.instance.ref().child(p.photoFileName).delete();
  }

  static Future<List<PhotoMemo>> searchImage ({
    @required String createdBy, 
    @required List<String> searchLabels}) async{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();
      var results = <PhotoMemo>[];
      querySnapshot.docs.forEach((doc) {
        results.add(PhotoMemo.deserialize(doc.data(), doc.id));
      });

      return results;
  }

  static Future<List<Comment>> getComments(String docId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(docId)
      .collection(Constant.COMMENT_COLLECTION)
      .orderBy(PhotoMemo.TIMESTAMP, descending: true)
      .get();
    var results = <Comment>[];
    querySnapshot.docs.forEach((doc) {
      results.add(Comment.deserialize(doc.data(), doc.id));
    });
    return results;
  }

  static Future<String> addComment(Comment comment)async{
    var ref = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(comment.photoMemoId)
      .collection(Constant.COMMENT_COLLECTION)
      .add(comment.serialize());
    return ref.id;
  }

  static Future<void> deleteComment(Comment c) async {
    await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(c.photoMemoId)
      .collection(Constant.COMMENT_COLLECTION)
      .doc(c.docId)
      .delete();
  }

  static Future<void> updateComment(String photoMemoId, String docId, Map<String, dynamic> updateInfo) async{
    await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(photoMemoId)
      .collection(Constant.COMMENT_COLLECTION)
      .doc(docId)
      .update(updateInfo);
  }

  static Future<MyUser> getUserProfileFromEmail({@required String email}) async {
    MyUser posterProfile;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .where(MyUser.EMAIL, isEqualTo: email)
      .get();
    querySnapshot.docs.forEach((doc) {
      posterProfile = MyUser.deserialize(doc.data(), doc.id);
    });

    return posterProfile;
  }

  static Future<void> addFollower({@required String posterEmail, @required String followerEmail }) async{
    MyUser posterProfile;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .where(MyUser.EMAIL, isEqualTo: posterEmail)
      .get();
    querySnapshot.docs.forEach((doc) {
      posterProfile = MyUser.deserialize(doc.data(), doc.id);
    });

    posterProfile.followers.add(followerEmail.trim());

    await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .doc(posterProfile.docId)
      .update({MyUser.FOLLOWERS : posterProfile.followers});
  }

  static Future<List<MyUser>> adminGetUserList(MyUser adminProfile) async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PROFILE_COLLECTION)
      .orderBy(MyUser.EMAIL, descending: false)
      .get();

    List<MyUser> userList = [];

    querySnapshot.docs.forEach((doc) {
      userList.add(MyUser.deserialize(doc.data(), doc.id));
    });

    return userList;
  }

  static Future<List<PhotoMemo>> adminGetUserPhotoMemoList(String email) async{
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .where(PhotoMemo.CREATED_BY, isEqualTo: email)
      .orderBy(PhotoMemo.TIMESTAMP, descending: true)
      .get();

    List<PhotoMemo> userPhotoMemoList = [];

    querySnapshot.docs.forEach((doc){
      userPhotoMemoList.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });

    return userPhotoMemoList;
  }

  static Future<void> adminRemovePhotoMemo(String docId) async {
    await FirebaseFirestore.instance
      .collection(Constant.PHOTOMEMO_COLLECTION)
      .doc(docId)
      .delete();
  }
}