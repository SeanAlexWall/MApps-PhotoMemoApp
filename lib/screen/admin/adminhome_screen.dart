import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/admin/userdetails_screen.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget{
  static const routeName = "/adminHomeScreen";

  @override
  State<StatefulWidget> createState() {
    return AdminHomeState();
  }
}

class AdminHomeState extends State<AdminHomeScreen> {
  _Controller con;
  User user;
  MyUser userProfile;
  List<MyUser> userList;
  
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
    userList ??= args[Constant.ARG_USER_PROFILE_LIST];

    return Scaffold(
      appBar: AppBar(title: Text("Admin Home")),
      body: (userList.length == 0)? 
        Text(
          "No Users Found!",
          style: Theme.of(context).textTheme.headline5,
        )
      : ListView.builder(
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) => Container(
          child: ListTile(
            leading: (userList[index].photoURL == null)? Icon(Icons.person) 
              : MyImage.network(
                url: userList[index].photoURL,
                context: context,
              ),//leading
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text(userList[index].email),
            onTap: () => con.onTap(index),
          ),
        ),
      )
    );
  }
}

class _Controller {
  AdminHomeState state;

  _Controller(this.state);

  void onTap(int index) async {
    try {
      List<PhotoMemo> userPhotoMemoList = 
        await FirebaseController.adminGetUserPhotoMemoList(state.userList[index].email);
      Navigator.pushNamed(
        state.context, 
        UserDetailsScreen.routeName,
        arguments: {
          Constant.ARG_USER : state.user,
          Constant.ARG_USER_PROFILE : state.userProfile,
          Constant.ARG_ONE_USER_PROFILE : state.userList[index],
          Constant.ARG_PHOTOMEMOLIST : userPhotoMemoList,
        }
      );
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: "Get userPhotoMemoList error",
        content: "$e",
      );
    }
  }
}