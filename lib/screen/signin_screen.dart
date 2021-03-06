import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/model/myuser.dart';
import 'package:PhotoMemoApp/model/photomemo.dart';
import 'package:PhotoMemoApp/screen/myview/myAppTheme.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:PhotoMemoApp/screen/signup_screen.dart';
import 'package:PhotoMemoApp/screen/test.dart';
import 'package:PhotoMemoApp/screen/userhome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'myview/conifg.dart';

class SignInScreen extends StatefulWidget{
  static const routeName = "/signInScreen";

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
  
}

class _SignInState extends State<SignInScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'PhotoMemo',
                  style: TextStyle(fontFamily: "Lobster", fontSize: 40.0),
                ),
                Text(
                  'Sign in, please!',
                  style: TextStyle(fontFamily: "Lobster"),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Email",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Password",
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                RaisedButton(
                  child: Text(
                    "Sign In",
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: con.signIn,
                ),
                SizedBox(height: 15),
                FlatButton(
                  onPressed: con.signUp,
                  child: Text(
                    "Create a new account",
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                FlatButton(
                  onPressed: () => Navigator.pushNamed(context, TestScreen.routeName),
                  child: Text(
                    "Test",
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}


class _Controller{
  _SignInState state;
  _Controller(this.state);
  String email;
  String password;

  String validateEmail(String value){
    if (value.contains('@') && value.contains('.')) return null;
    else return 'invalid email address';
  }

  void saveEmail(String value){
    email = value;
  }

  String validatePassword(String value){
    if (value.length < 6) return 'too short';
    else return null;
  }

  void savePassword(String value){
    password = value;
  }

  Future<void> signIn() async {
    if(!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    User user;
    MyUser userProfile;
    MyDialog.circularProgressStart(state.context);

    try{
      user = await FirebaseController.signIn(email: email, password: password);
      userProfile = await FirebaseController.getUserProfile(user.uid, user.email);
    }catch(e){
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Sign In Error',
        content: e.toString(),
      );
      return;
    }

    if(userProfile.unbanDate != null){
      if(userProfile.unbanDate.isAfter(DateTime.now())){
        MyDialog.circularProgressStop(state.context);
        MyDialog.info(
          context: state.context,
          title: "You are banned!",
          content: "You have been banned until " +
            "${userProfile.unbanDate.month}/" +
            "${userProfile.unbanDate.day}/" +
            "${userProfile.unbanDate.year}"
        );
        await FirebaseController.signOut();
        return;
      }
    }

    print(userProfile.appColor);
    if(userProfile.appColor == null) userProfile.appColor = MyAppTheme.GREEN;
    if(userProfile.darkMode == null) userProfile.darkMode = true;

    currentTheme.setColor(userProfile.appColor);
    currentTheme.setBrightness(userProfile.darkMode);

    try{
      List<PhotoMemo> photoMemoList = 
        await FirebaseController.getPhotoMemoList(email: user.email);
      MyDialog.circularProgressStop(state.context);
      Navigator.pushNamed(
        state.context, 
        UserHomeScreen.routeName, 
        arguments: {
          Constant.ARG_USER : user,
          Constant.ARG_PHOTOMEMOLIST : photoMemoList,
          Constant.ARG_USER_PROFILE : userProfile,
        },
      );
    } catch(e){
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Firestore getPhotoMemoList error",
        content: "$e",
      );
    }


  }

  void signUp(){
    Navigator.pushNamed(state.context, SignUpScreen.routeName);
  }

}
