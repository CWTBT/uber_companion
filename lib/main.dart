import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber Companion',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Uber Companion'),
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
  AppState _state = AppState.USER_TYPE_MENU;

  void initState() {
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    switch(_state) {
      case AppState.USER_TYPE_MENU:
        return _buildUserTypeMenu(_screenWidth);
      case AppState.DRIVER_MENU:
        return Scaffold();
      case AppState.PASSENGER_MENU:
        return Scaffold();
    }
  }

  Widget _buildUserTypeMenu(double screenWidth) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          children: <Widget>[
            _buildButton(screenWidth, UserType.DRIVER),
            _buildButton(screenWidth, UserType.PASSENGER),
          ]
      ),
    );
  }

  Widget _buildButton(double screenWidth, UserType user) {
    return Expanded (
        flex: 2,
        child: new GestureDetector(
            onTap: (){
              _printUserType(user);
            },
            child: new Container(
                color: _getColorForUserType(user),
                width: screenWidth,
                child: Center(
                  child: _getUserTypeText(user),
                )
            )
        )
    );
  }

  void _printUserType(UserType user) {
    switch(user) {
      case UserType.DRIVER:
        print("I am a DRIVER");
        break;
      case UserType.PASSENGER:
        print("I am a PASSENGER");
        break;
    }
  }

  Widget _getUserTypeText(UserType user) {
    switch(user) {
      case UserType.DRIVER:
        return Text("I am a DRIVER");
      case UserType.PASSENGER:
        return Text("I am a PASSENGER");
    }
  }

  Color _getColorForUserType(UserType user) {
    switch(user) {
      case UserType.DRIVER:
        return Colors.lightGreen[100];
      case UserType.PASSENGER:
        return Colors.lightGreen[600];
    }
  }
}

enum UserType{
  DRIVER,
  PASSENGER
}

enum AppState{
  USER_TYPE_MENU,
  DRIVER_MENU,
  PASSENGER_MENU
}
