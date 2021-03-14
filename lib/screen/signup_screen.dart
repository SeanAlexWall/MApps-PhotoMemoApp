import 'package:PhotoMemoApp/controller/firebasecontroller.dart';
import 'package:PhotoMemoApp/screen/myview/mydialog.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget{
  static const routeName = "/signUpScreeen";

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
  
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create an Account")),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Create an Account",
                  style: Theme.of(context).textTheme.headline5
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
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePasswordConfirm,
                ),
                (con.passwordErrorMessage == null)?
                SizedBox(width: 1,)
                : Text(
                  con.passwordErrorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                RaisedButton(
                  child: Text(
                    "Create Account",
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: con.createAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class _Controller {
  _SignUpState state;
  _Controller(this.state);
  String email, password, passwordConfirm;
  String passwordErrorMessage;

  String validateEmail(String value){
    if(value.contains('@') && value.contains('.')) return null;
    else return "Invalid email";
  }

  void saveEmail(String value){
    email = value;
  }

  String validatePassword(String value){
    if(value.length >= 6) return null;
    else return "Too short";
  }

  void savePassword(String value){
    password = value;
  }
  void savePasswordConfirm(String value){
    passwordConfirm = value;
  }


  void createAccount() async {
    if(!state.formKey.currentState.validate()) return;

    state.render(() => passwordErrorMessage = null);
    state.formKey.currentState.save();

    if(password != passwordConfirm){
      state.render((){
        passwordErrorMessage = 'Passwords do not match';
      });
      return;
    }

    try{
      await FirebaseController.createAccount(email: email, password: password);
      Navigator.pop(state.context);
      MyDialog.info(
        context: state.context,
        title: "Account Created!",
        content: 'Please sign in',
      );
    }
    catch(e){
      MyDialog.info(
        context: state.context,
        title: 'Cannot create',
        content: '$e',
      );
    }

  }
}