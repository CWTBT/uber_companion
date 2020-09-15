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
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AppState _state = AppState.USER_TYPE_MENU;
  List<BluetoothService> _services = new List<BluetoothService>();

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
      case AppState.USER_TYPE_MENU:
        return _buildUserTypeMenu(_screenWidth);
      case AppState.DRIVER_MENU:
        return _buildDriverMenu();
      case AppState.PASSENGER_MENU:
        return _buildPassengerMenu();
      case AppState.DEVICE_LIST:
        return _buildDeviceListMenu();
      case AppState.SERVICES_LIST:
        return _buildServicesListMenu();
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

  Widget _buildPassengerMenu() {
    return Scaffold (
      appBar: AppBar (
        title: Text("Passenger Menu"),
      ),
      body: Column(
        children: <Widget>[
          _buildButton(
            text:"Sync to Driver",
            onPressedLogic: _bluetoothOnPressed,
            buttonColor: Colors.blue,
            height: 50
          ),
          _buildPassengerRequestList(),
        ]
      )
    );
  }

  void _bluetoothOnPressed() {
    print("Bluetooth Button Pressed");
    print("Devices: " + widget.devicesList.toString());
    //https://blog.kuzzle.io/communicate-through-ble-using-flutter
    setState(() {
      _state = AppState.DEVICE_LIST;
    });
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
      ]
    );
  }

  void musicRequestOnPressed() {
    print("Music Change");
  }

  Widget _buildDriverMenu() {
    return Scaffold (
        appBar: AppBar (
          title: Text("Driver Menu"),
        ),
        body: Column(
            children: <Widget>[
              _buildButton(
                  text:"Sync to Passenger",
                  onPressedLogic: _bluetoothOnPressed,
                  buttonColor: Colors.blue,
                  height: 50
              ),
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
              Text(device.name == '' ? '(unknown device)': device.name),
              FlatButton(
                color: Colors.blue,
                child: Text("Connect"),
                onPressed: () {
                  _connectToDevice(device);
                  setState(() {
                    _state = AppState.SERVICES_LIST;
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
    _services = await device.discoverServices();
  }

  Widget _buildServicesListMenu() {
    return Scaffold (
      appBar: AppBar(
        title: Text("Services Found"),
      ),
      body: _buildServicesList(),
    );
  }

  // https://blog.kuzzle.io/communicate-through-ble-using-flutter
  Widget _buildServicesList() {
    List<Container> containers = new List<Container>();
    for (BluetoothService service in _services) {
      containers.add(
        Container(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column (
                  children: <Widget>[
                    Text(service.uuid.toString()),
                  ]
                )
              )
            ]
          )
        )
      );
    }

    return ListView(
        padding: EdgeInsets.all(8),
        children: <Widget> [
          ...containers,
        ]
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
  DEVICE_LIST,
  SERVICES_LIST
}
