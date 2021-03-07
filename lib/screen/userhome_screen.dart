import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHomeScreen extends StatefulWidget{
  static const routeName = "/userHomeScreen";

  @override
  State<StatefulWidget> createState() {
    return UserHomeState();
  }
}

class UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;

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
    user ??= args['user'];
    return Scaffold(
      appBar: AppBar(
        title: Text("User Home"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName ?? 'N/A' ), 
              accountEmail: Text(user.email),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Sign Out"),
              onTap: con.signOut,
            ),
          ],
        ),
      ),
      body: Text("User Home ${user.email}"),
    );
  }

}

class _Controller {
  UserHomeState state;

  _Controller(this.state);

  void signOut() async{
    try{
      await FirebaseController.signOut();
    }
    catch (e) {
      //do nothing
    }

    Navigator.of(state.context).pop();
    Navigator.of(state.context).pop();
  }
}