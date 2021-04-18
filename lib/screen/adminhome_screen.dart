import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/screen/myview/myImage.dart';
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
          "No PhotoMemos Found!",
          style: Theme.of(context).textTheme.headline5,
        )
      : ListView.builder(
        itemCount: userList.length,
        itemBuilder: (BuildContext context, int index) => Container(
          child: ListTile(
            leading: (userList[index].photoURL == null)? null 
              : MyImage.network(
                url: userList[index].photoURL,
                context: context,
              ),//leading
            trailing: Icon(Icons.keyboard_arrow_right),
            title: Text(userList[index].email),
            
          ),
        ),
      )
    );
  }
}

class _Controller {
  AdminHomeState state;

  _Controller(this.state);
}