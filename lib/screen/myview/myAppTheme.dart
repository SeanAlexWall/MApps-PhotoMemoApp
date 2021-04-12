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

  void setColor(String value){
    color = colorOptions[value];
    notifyListeners();
  }


  static const GREEN = "green";
  static const BLUE = "blue";
  static const RED = "red";
  static const PURPLE = "purple";
  static const YELLOW = "yellow";
  static const ORANGE = "orange";  

  static const Map<String, MaterialColor> colorOptions = {
    GREEN : Colors.green,
    BLUE : Colors.blue,
    RED : Colors.red,
    PURPLE : Colors.purple,
    YELLOW : Colors.yellow,
    ORANGE : Colors.orange,
  };
}