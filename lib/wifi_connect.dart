
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:wifi/wifi.dart';



class wificonnect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  String wifiName;
  String password='BF8459BF';
  MethodChannel _methodChannel =
  MethodChannel('plugins.flutter.io/connectivity');
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() => _connectionStatus = result.toString());
        });
  }
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  Future<Null> initConnectivity() async {
    String connectionStatus;
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } on PlatformException catch (e) {
      print(e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _connectionStatus = connectionStatus;
    });
  }
  Future<String> getWifiName() async {
    wifiName = await _methodChannel.invokeMethod('wifiName');
    print("wifiNamed$wifiName");
    if (wifiName == '<unknown ssid>') wifiName = null;
    return wifiName;
  }
  Future<Null> connection() async {
//    Wifi.connection(wifiName, password).then((v) {
       Wifi.connection("IGWIFI", "BF8459BF").then((v) {
      print(v);
    });
  }


  void showWifiAlert() async {
    var wifiEnabled = await getWifiStatus();
    if (wifiEnabled) {
      print('Enabled');
    }
    else {
      print('Not Enabled');
    }
  }

  Future<bool> getWifiStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;

    }
  }
  @override
  Widget build(BuildContext context) {
    getWifiName();
//    showWifiAlert();
    connection();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(child: Text('Connection Status: $_connectionStatus\n')),
    );

  }


}