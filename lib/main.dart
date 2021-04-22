import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/screen/addphotomemo_screen.dart';
import 'package:PhotoMemoApp/screen/admin/adminhome_screen.dart';
import 'package:PhotoMemoApp/screen/admin/userdetails_screen.dart';
import 'package:PhotoMemoApp/screen/comments_screen.dart';
import 'package:PhotoMemoApp/screen/detailedview_screen.dart';
import 'package:PhotoMemoApp/screen/myview/conifg.dart';
import 'package:PhotoMemoApp/screen/profile_screen.dart';
import 'package:PhotoMemoApp/screen/sharedwith_screen.dart';
import 'package:PhotoMemoApp/screen/signin_screen.dart';
import 'package:PhotoMemoApp/screen/signup_screen.dart';
import 'package:PhotoMemoApp/screen/test.dart';
import 'package:PhotoMemoApp/screen/userhome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
  // This widget is the root of your application.
  
}

class AppState extends State<PhotoMemoApp> {
  Color primaryColor;
  bool darkMode;

  @override
  void initState() {
    super.initState();
    currentTheme.addListener((){
      print("Changes");
      setState((){});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      title: 'Flutter Demo',
      theme: currentTheme.currentTheme(),

      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName : (context) => SignInScreen(),
        UserHomeScreen.routeName : (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName : (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName : (context) => DetailedViewScreen(),
        SignUpScreen.routeName : (context) => SignUpScreen(),
        SharedWithScreen.routeName : (context) => SharedWithScreen(),
        CommentsScreen.routeName : (context) => CommentsScreen(),
        ProfileScreen.routeName : (context) => ProfileScreen(),
        TestScreen.routeName : (context) => TestScreen(),
        AdminHomeScreen.routeName : (conext) => AdminHomeScreen(),
        UserDetailsScreen.routeName : (context) => UserDetailsScreen(), 
      },
    );
  }
}

