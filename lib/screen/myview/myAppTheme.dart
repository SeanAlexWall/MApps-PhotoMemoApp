import 'package:flutter/material.dart';

class MyAppTheme with ChangeNotifier{
  bool darkMode = true;
  MaterialColor color = Colors.green;

  ThemeData currentTheme (){
    return ThemeData(
      brightness: darkMode? Brightness.dark : Brightness.light,
      primaryColor: color,
      primarySwatch: color,
    );
  }

  void switchBrightness(){
    darkMode = darkMode? false : true;
    notifyListeners();
  }

  void setBrightness(bool value){
    darkMode = value;
    notifyListeners();
  }

  void setColor(Color value){
    color = value;
    notifyListeners();
  }
}