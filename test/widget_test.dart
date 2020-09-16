// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:uber_companion/main.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  // I have only recently considered that the dart VM probably
  // doesn't have bluetooth functionality, and thus I
  // suspect these two tests can never pass.

  test("Bluetooth available", () async {
    final FlutterBlue flutterBlue = FlutterBlue.instance;
    bool availability = await flutterBlue.isAvailable;
    expect(availability, true);
  });

  test('Device list is successfully populated', () async {
    final FlutterBlue flutterBlue = FlutterBlue.instance;
    int resultsCount = 0;

    flutterBlue.startScan(timeout: Duration(seconds: 5));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        resultsCount += 1;
      }
    });

    flutterBlue.stopScan();

    expect(resultsCount, greaterThan(0));
  });

}
