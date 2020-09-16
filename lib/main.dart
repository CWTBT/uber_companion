import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppState _state = AppState.STARTUP;

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    print("Called addDeviceTolist");
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    switch(_state) {
      case AppState.STARTUP:
        return _buildDeviceListMenu();
      case AppState.CONNECTED:
        return _buildUserTypeMenu(_screenWidth);
    }
  }

  Widget _buildDeviceListMenu() {
    return Scaffold (
      appBar: AppBar(
        title: Text("Devices Found"),
      ),
      body: _buildDeviceList(),
    );
  }

  // https://blog.kuzzle.io/communicate-through-ble-using-flutter
  Widget _buildDeviceList() {
    List<Container> containers = new List<Container>();

    // Adds a button to skip the connection screen, in case testers
    // don't have an extra device handy
    containers.add(
      Container(
        height: 50,
        child: Row (
          children: <Widget> [
            Text("SKIP CONNECTION (for testing)"),
            _buildButton(
              text: "\"Connect\"",
              onPressedLogic: () {
                setState(() {
                  _state = AppState.CONNECTED;
                });
              },
              buttonColor: Colors.red[200],
              height: 50
            )
          ]
        )
      )
    );

    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row (
            children: <Widget>[
              Text(device.name == '' ? '(unknown device)': device.name),
              FlatButton(
                color: Colors.lightGreen[300],
                child: Text("Connect"),
                onPressed: () {
                  _connectToDevice(device);
                  setState(() {
                    _state = AppState.CONNECTED;
                  });
                },
              )
            ],
          ),
        ),
      );
    }

    return ListView(
        padding: EdgeInsets.all(10),
        children: <Widget> [
          ...containers,
        ]
    );
  }

  void _connectToDevice(BluetoothDevice device) async{
    await device.connect();
    widget.flutterBlue.stopScan();
  }

  Widget _buildUserTypeMenu(double screenWidth) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          children: <Widget>[
            _buildUserTypeButtons(screenWidth, UserType.DRIVER),
            _buildUserTypeButtons(screenWidth, UserType.PASSENGER),
          ]
      ),
    );
  }

  Widget _buildUserTypeButtons(double screenWidth, UserType user) {
    return Expanded (
        flex: 2,
        child: new GestureDetector(
            onTap: (){
              _buildOnTapForUserType(user);
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

  void _buildOnTapForUserType(UserType user) {
    switch(user) {
      case UserType.DRIVER:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DriverMenu())
        );
        break;
      case UserType.PASSENGER:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PassengerMenu())
        );
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

//https://stackoverflow.com/questions/54792376/flutter-add-result-to-navigator-when-system-back-button-is-pressed
class PassengerMenu extends StatefulWidget {
  PassengerMenu({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _PassengerMenuState createState() => _PassengerMenuState();
}

class _PassengerMenuState extends State<PassengerMenu> {
  RequestState _state = RequestState.NONE;

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_state == RequestState.NONE) return _buildPassengerMenuBody();
    else return _buildDriverViewFromState();
  }

  Widget _buildDriverViewFromState() {
    Color _color = Colors.white;
    String _type = "";

    switch(_state) {
      case RequestState.NONE:
        print("How did this happen?");
        return Scaffold();
      case RequestState.MUSIC:
        _color = Colors.limeAccent;
        _type = "Music change";
        break;
      case RequestState.TEMP:
        _color = Colors.greenAccent[100];
        _type = "Temperature change";
        break;
      case RequestState.STOPS:
        _color = Colors.yellowAccent[400];
        _type = "Extra stops";
        break;
      case RequestState.COMM:
        _color = Colors.teal[300];
        _type = "Communcation level";
        break;
    }

    return WillPopScope(
      child: _buildDriverViewBody(context, _color, _type),
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
    );
  }

  Widget _buildPassengerMenuBody() {
    return Scaffold (
        appBar: AppBar (
          title: Text("Passenger Menu"),
        ),
        body: Column(
            children: <Widget>[
              _buildPassengerRequestList(),
            ]
        )
    );
  }

  Widget _buildPassengerRequestList() {

    return Column(
        children: <Widget>[
          _buildButton(
              text: "Request Music Change",
              onPressedLogic: musicRequestOnPressed,
              buttonColor: Colors.lightGreen[300],
              height: 100
          ),
          _buildButton(
              text: "Request Temperature Change",
              onPressedLogic: tempRequestOnPressed,
              buttonColor: Colors.lightGreen[300],
              height: 100
          ),
          _buildButton(
              text: "Request Additional Stop",
              onPressedLogic: stopRequestOnPressed,
              buttonColor: Colors.lightGreen[300],
              height: 100
          ),
          _buildButton(
              text: "Adjust Communication Level",
              onPressedLogic: commChangeOnPressed,
              buttonColor: Colors.lightGreen[300],
              height: 100
          ),

        ]
    );
  }

  void musicRequestOnPressed() {
    print("Music");
    setState(() {
      _state = RequestState.MUSIC;
    });
  }

  void tempRequestOnPressed() {
    print("Temp");
    setState(() {
      _state = RequestState.TEMP;
    });
  }

  void stopRequestOnPressed() {
    print("Stop");
    setState(() {
      _state = RequestState.STOPS;
    });
  }

  void commChangeOnPressed() {
    print("Communication");
    setState(() {
      _state = RequestState.COMM;
    });
  }

  Widget _buildDriverViewBody(BuildContext context, Color color, String requestType) {
    return Scaffold (
        appBar: AppBar (
          title: Text("Driver Menu"),
        ),
        body: Column(
            children: <Widget>[
              Expanded(
                child: AnimatedContainer(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                    duration: Duration(seconds: 3),
                    child: GestureDetector(
                      //https://stackoverflow.com/questions/52965799/flutter-gesturedetector-not-working-with-containers-in-stack
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _state = RequestState.NONE;
                        });
                      },
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(requestType+" request received."),
                              Text("Tap to acknowledge request."),
                            ],
                          )
                        )
                    )
                ),
              )
            ],
        )
    );
  }
}

class DriverMenu extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: _buildDriverMenu(context),
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
    );
  }

  Widget _buildDriverMenu(BuildContext context) {
    return Scaffold (
        appBar: AppBar (
          title: Text("Driver Menu"),
        ),
        body: Column(
            children: <Widget>[
              Expanded(
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  duration: Duration(seconds: 3),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      }
                  )
                ),
              )
            ]
        )
    );
  }
}

Widget _buildButton({
  String text,
  Function onPressedLogic,
  Color buttonColor = Colors.lightGreen,
  double height = 50}) {
  return new Container (
      height: height,
      margin: EdgeInsets.all(10),
      color: buttonColor,
      child: new FlatButton (
          onPressed: onPressedLogic,
          child: Center (
            child: Text(text),
          )
      )
  );
}

enum UserType{
  DRIVER,
  PASSENGER
}

enum AppState{
  STARTUP,
  CONNECTED
}

enum RequestState {
  NONE,
  MUSIC,
  TEMP,
  STOPS,
  COMM
}
