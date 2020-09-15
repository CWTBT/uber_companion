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
  AppState _state = AppState.USER_TYPE_MENU;

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
        return _buildDriverMenu();
      case AppState.PASSENGER_MENU:
        return _buildPassengerMenu();
      case AppState.DEVICE_LIST:
        return _buildDeviceListMenu();
    }
  }

  _addDeviceTolist(final BluetoothDevice device) {
    print("Called addDeviceTolist");
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
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

  Widget _buildPassengerMenu() {
    return Scaffold (
      appBar: AppBar (
        title: Text("Passenger Menu"),
      ),
      body: Column(
        children: <Widget>[
          _buildBluetoothButton(UserType.PASSENGER),
          _buildPassengerRequestList(),
        ]
      )
    );
  }

  Widget _buildPassengerRequestList() {
    return Column(
      children: <Widget>[
        _buildMusicChangeRequestButton(),
      ]
    );
  }

  Widget _buildMusicChangeRequestButton() {
    return new Container (
        height: 100,
        margin: EdgeInsets.all(10),
        color: Colors.lightGreen[300],
        child: new FlatButton (
            onPressed: (){
              print("Music Change");
            },
            child: Center (
                child: Text("Request Music Change")
            )
        )
    );
  }

  Widget _buildDriverMenu() {
    return Scaffold (
        appBar: AppBar (
          title: Text("Driver Menu"),
        ),
        body: Column(
            children: <Widget>[
              _buildBluetoothButton(UserType.DRIVER),
            ]
        )
    );
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
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Row (
            children: <Widget>[
              Text(device.id.toString()),
              FlatButton(
                color: Colors.blue,
                child: Text("Connect"),
                onPressed: () {
                  print("Connect button pressed!");
                }
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

  Widget _buildBluetoothButton(UserType type) {
    return new Container (
        height: 50,
        margin: EdgeInsets.all(10),
        color: Colors.blue,
        child: new FlatButton (
            onPressed: (){
              print("Bluetooth Button Pressed");
              print("Devices: " + widget.devicesList.toString());
              //https://blog.kuzzle.io/communicate-through-ble-using-flutter
              setState(() {
                _state = AppState.DEVICE_LIST;
              });
            },
            child: Center (
                child: _getBluetoothTextFor(type)
            )
        )
    );
  }

  // ignore: missing_return
  Text _getBluetoothTextFor(UserType type) {
    switch(type) {
      case UserType.DRIVER:
        return Text("Sync with Passenger");
      case UserType.PASSENGER:
        return Text("Sync with Driver");
    }
  }

  Widget _buildButton(double screenWidth, UserType user) {
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
        setState(() {
          _state = AppState.DRIVER_MENU;
        });
        break;
      case UserType.PASSENGER:
        setState(() {
          _state = AppState.PASSENGER_MENU;
        });
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
  PASSENGER_MENU,
  DEVICE_LIST
}
