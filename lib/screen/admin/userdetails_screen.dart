import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatefulWidget{
  static const routeName = "/UserDetailsScreen";

  @override
  State<StatefulWidget> createState() {
    return UserDetailsState();
  }
}

class UserDetailsState extends State<UserDetailsScreen> {
  _Controller con;
  User user;
  MyUser userProfile;
  MyUser oneUserProfile;
  List<PhotoMemo> userPhotoMemoList;
  GlobalKey<FormState> banKey = GlobalKey<FormState>();
  DateTime unbanDate;
  bool banMode = false;

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
    oneUserProfile ??= args[Constant.ARG_ONE_USER_PROFILE];
    userPhotoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    //I do it this way so that there is no difference between today at 9:37
    //and today at 10:54 or anything like that
    unbanDate ??= DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Scaffold(
      appBar: AppBar(title: Text("${oneUserProfile.email}")),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column( 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * .4,
                child:  (oneUserProfile.photoURL == null)? Icon(Icons.person) 
                : MyImage.network(
                  url: oneUserProfile.photoURL,
                  context: context,
                ),
              ),
              Text("Email: ${oneUserProfile.email} "),
              Text("Display Name: ${oneUserProfile.displayName} "),
              Text("App Color: ${oneUserProfile.appColor}"),
              Text("Followers: ${oneUserProfile.followers} "),
              (oneUserProfile.unbanDate == null)? SizedBox(height: 1)
              : Text(
                "Banned until ${oneUserProfile.unbanDate.month}/" +
                "${oneUserProfile.unbanDate.day}/" +
                "${oneUserProfile.unbanDate.year}"),
              RaisedButton(
                child: banMode? Text("Cancel") : Text("Ban"),
                onPressed: con.banButton
              ),
              banMode? Text("When should this user be unbanned?") : SizedBox(height: 1),
              banMode? Form(
                key: banKey,
                child: Container(
                  width: MediaQuery.of(context).size.width *.7,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'MM/DD/YYYY',
                            errorMaxLines: 10,
                          ),
                        autocorrect: true,
                        validator: con.validateUnbanDate,
                        onSaved: con.saveUnbanDate,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          child: Text("Ban"),
                          onPressed: con.banUser,
                        )
                      )
                    ],
                  ),
                ),
              ) : SizedBox(height: 1),
              (userPhotoMemoList.length == 0)? 
              Text(
                "No PhotoMemos Found!",
                style: Theme.of(context).textTheme.headline5,
              )
              : ListView.builder(
                shrinkWrap: true,
                itemCount: userPhotoMemoList.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  child: ListTile(
                    leading: MyImage.network(
                      url: userPhotoMemoList[index].photoURL,
                      context: context,
                    ),
                    title: Text(
                      userPhotoMemoList[index].title,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (userPhotoMemoList[index].memo.length >= 20)? 
                            userPhotoMemoList[index].memo.substring(0, 20) + "..."
                            : userPhotoMemoList[index].memo,
                        ), 
                        Text("Created By ${userPhotoMemoList[index].createdBy}"),
                        Text("Shared With ${userPhotoMemoList[index].sharedWith}"),
                        Text("Updated At ${userPhotoMemoList[index].timestamp}"),
                        Row(
                          children: [
                            RaisedButton(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble,
                                  ),
                                  Text(
                                    " ${userPhotoMemoList[index].numComments}",
                                    //style: CustomTextThemes.alert1(context),
                                  )
                                ]
                              ),
                              onPressed: null //() => con.comments(index),
                            ),
                            SizedBox(width: 10.0),
                            Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                  ),
                                  Text(
                                    userPhotoMemoList[index].numLikes == null? 
                                    " 0" : " ${userPhotoMemoList[index].numLikes}",
                                    //style: CustomTextThemes.alert1(context)
                                  )
                                ]
                              ),
                            ),
                            SizedBox(width: 10.0),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => con.delete(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //onTap: () => con.onTap(index),
                    //onLongPress: () => con.onLongPress(index),
                  ),
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
  UserDetailsState state;

  _Controller(this.state);

  void delete(int index) async {
    try{
      MyDialog.circularProgressStart(state.context);
      await FirebaseController.adminRemovePhotoMemo(state.userPhotoMemoList[index].docId);
      MyDialog.circularProgressStop(state.context);
      state.render((){
        state.userPhotoMemoList.removeAt(index);
      }); //refresh
    }catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Admin delete photomemo error",
        content: "$e",
      );
    }
  }

  void banButton(){
    state.render((){state.banMode = state.banMode? false : true;});
  }

  String validateUnbanDate(String val){
    String returnMessage;
    List<String> date = val.split("/");

    //should be in format mm/dd/yyyy

    int month = int.tryParse(date[0]);
    int day = int.tryParse(date[1]);
    int year = int.tryParse(date[2]);

    if(month == null || day == null || year == null) 
      returnMessage = "Incorrect Formatting ";
    else{
      if(month < 1 || month > 12){
        returnMessage ??= "";
        returnMessage += "Month must be between 1 and 12 inclusive\n";
      }
      else{
        switch(month){
          case 4:
          case 6:
          case 9:
          case 11:
            if(day < 1 || day > 30){
              returnMessage ??= "";
              returnMessage += "Day for this month must be between 1 and 30 inclusive\n";
            }
            break;
          case 2:
            //leapYear?
            int lastDayInFeb = (year %4 == 0)? 29 : 28; 
            if(day < 1 || day > lastDayInFeb){
              returnMessage ??= "";
              returnMessage += "Day for this month must be between 1 and $lastDayInFeb inclusive\n";
            }
            break;
          default:
            if(day < 1 || day > 31){
              returnMessage ??= "";
              returnMessage += "Day for this month must be between 1 and 31 inclusive\n";
            }
            break;
        }//switch
      }//else
      DateTime now = DateTime.now();
      DateTime date1 = DateTime.utc(year, month, day);
      if(date1.isBefore(now)){
        returnMessage ??= "";
        returnMessage += "Unban Date must be in the future\n";
      }
    }//else
    return returnMessage;
  }//validateUnbanDate

  void saveUnbanDate(String val){
    List<String> date = val.split("/");

    //will be in format mm/dd/yyyy

    int month = int.tryParse(date[0]);
    int day = int.tryParse(date[1]);
    int year = int.tryParse(date[2]);

    state.unbanDate = DateTime.utc(year, month, day);
  }

  void banUser() async {
    if(!state.banKey.currentState.validate()) return;

    state.banKey.currentState.save();

    try{
      await FirebaseController.updateUserProfile(
        state.oneUserProfile.docId,
        { MyUser.UNBAN_DATE: state.unbanDate },
      );
      state.oneUserProfile.unbanDate = state.unbanDate;
      state.banKey.currentState.reset();
      state.render((){state.banMode = false;});
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Update unbanDate error",
        content: "$e",
      );
    }
  }
}