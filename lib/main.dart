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
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.lightGreen[100],
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text("I am a Driver.")
              )
            )
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.lightGreen[600],
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Text("I am a Rider.")
              )
            )
          )
        ]
      ),
    );
  }
}
