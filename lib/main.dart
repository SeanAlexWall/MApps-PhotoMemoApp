import 'package:PhotoMemoApp/model/constant.dart';
import 'package:PhotoMemoApp/screen/addphotomemo_screen.dart';
import 'package:PhotoMemoApp/screen/comments_screen.dart';
import 'package:PhotoMemoApp/screen/detailedview_screen.dart';
import 'package:PhotoMemoApp/screen/sharedwith_screen.dart';
import 'package:PhotoMemoApp/screen/signin_screen.dart';
import 'package:PhotoMemoApp/screen/signup_screen.dart';
import 'package:PhotoMemoApp/screen/userhome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PhotoMemoApp());
}

class PhotoMemoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.green,
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: SignInScreen.routeName,
      routes: {
        SignInScreen.routeName : (context) => SignInScreen(),
        UserHomeScreen.routeName : (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName : (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName : (context) => DetailedViewScreen(),
        SignUpScreen.routeName : (context) => SignUpScreen(),
        SharedWithScreen.routeName : (context) => SharedWithScreen(),
        CommentsScreen.routeName : (context) => CommentsScreen(),
      },
    );
  }
}

