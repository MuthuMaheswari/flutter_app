import 'package:flutter/material.dart';
import 'package:flutter_app/Tablayout.dart';
import 'package:flutter_app/wifi_connect.dart';
import 'connect.dart';
import 'chart.dart';
import 'Download_upload.dart';



void main() => runApp(new HelloWorldApp());

class HelloWorldApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new connect()
    );
  }
}




