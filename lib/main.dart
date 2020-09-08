import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          buildMainMenuButton(context, UserType.DRIVER),
          buildMainMenuButton(context, UserType.PASSENGER),
        ]
      ),
    );
  }
}

Widget buildMainMenuButton(BuildContext context, UserType user) {
  var screenWidth = MediaQuery.of(context).size.width;
  return Expanded(
      flex: 2,
      child: _buildButtonChild(screenWidth, user),
  );
}

Widget _buildButtonChild(double screenWidth, UserType user) {
  switch(user) {
    case UserType.DRIVER:
      return Container(
        color: Colors.lightGreen[100],
        width: screenWidth,
        child: Center(
          child: Text("I am a DRIVER"),
        )
      );
    case UserType.PASSENGER:
      return Container(
          color: Colors.lightGreen[600],
          width: screenWidth,
          child: Center(
              child: Text("I am a PASSENGER"),
          )
      );
  }
}

enum UserType{
  DRIVER,
  PASSENGER
}
