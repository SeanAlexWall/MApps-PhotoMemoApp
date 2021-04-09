import 'package:flutter/material.dart';

import '../main.dart';
import 'myview/conifg.dart';

bool light = true;
class TestScreen extends StatefulWidget{
  static const routeName = "/testScreen";
  

  @override
  State<StatefulWidget> createState() {
    return TestState();
  }
  
}

class TestState extends State<TestScreen> {
  _Controller con;


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
    return Scaffold(
      appBar: AppBar(title: Text("Test")),
      body: Column(
        children: [
          Switch(
            value: currentTheme.darkMode,
            onChanged: (value){
              currentTheme.switchBrightness();
              setState((){});
            },
          ),
          Container(
            height: 15,
            width: 15,
            color: Color(Colors.red.value),
          )
        ],
      ),
    );
  }

}

class _Controller {
  TestState state;

  _Controller(this.state);

  void toggle(bool value){
    print(value);
    state.render((){

    });
  }
}