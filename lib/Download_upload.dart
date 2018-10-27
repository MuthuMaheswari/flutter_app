import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class DownloadFile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  final url = "http://192.168.2.99:4000/EnergyMeterDownload/1";
  var progressString = "";
  var loading;
  var upload;
  bool complete = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: loading,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loading = new ListView(
      children: <Widget>[
        new Center(
          child: Text('Pull to refresh'),
        ),
        SizedBox(
          height: 200.0,
//        child: chart,
        ),
      ],
    );
  }

  Future<void> downloadFile() async {

    setState(() {
      loading = Container(
        height: 120.0,
        width: 200.0,
//          child: Card(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 10.0),
            Text(
              "downloading file:$progressString",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    });

    Dio dio = Dio();
    var dir = await getApplicationDocumentsDirectory();
    await dio.download(url, "${dir.path}/filename.bin",
        // Listen the download progress.
        onProgress: (received, total) {
          print((received / total * 100).toStringAsFixed(0) + "%");
          setState(() {
            progressString = (received / total * 100).toStringAsFixed(0) + "%";
          });
        });
    setState(() {
      progressString = "Complete";
    });
    print("Download Complete");
    setState(() {
      uploadfiles();
      setState(() {
        loading = new ListView(
          children: <Widget>[
            new Text('Installing your updates'),
            new Center(
              child: new LinearProgressIndicator(),
            ),
            new Text('Do not switch Network'),
          ],
        );
      });
    });
  }

  Future<Null> _handleRefresh() async {
    await new Future.delayed(new Duration(seconds: 3));
    downloadFile();
    return null;
  }


  uploadfiles() async {
    var uri = Uri.parse("http://192.168.2.250/update");
    var dir = await getApplicationDocumentsDirectory();
    var request = new http.MultipartRequest("POST", uri);
    request.fields['user'] = 'john@doe.com';
    var multipartFile =
    await MultipartFile.fromPath("package", "${dir.path}/filename.bin");
    request.files.add(multipartFile);
    request.send().then((response) {
      if (response.statusCode == 200) print("Uploaded!");
      setState(() {
        loading = new Center(
          child: Text('Uploaded'),
        );
      });
    });
  }

}
