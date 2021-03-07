import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:PhotoMemoApp/screen/userhome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              )
            ],
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
    try{
      user = await FirebaseController.signIn(email: email, password: password);
    }catch(e){
      MyDialog.info(
        context: state.context,
        title: 'Sign In Error',
        content: e.toString(),
      );
      return;
    }

    Navigator.pushNamed(
      state.context, 
      UserHomeScreen.routeName, 
      arguments: {
        'user' : user
      },
    );
  }

}
