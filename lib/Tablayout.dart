import 'package:flutter/material.dart';
import 'package:flutter_app/Download_upload.dart';
import 'package:flutter_app/chart.dart';
import 'package:flutter_app/connect.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


class Tablayout extends StatelessWidget {
  TextEditingController ssidController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                new Tab(text: "ChangePassword"),
                new Tab(text: "CheckforUpdates"),
                new Tab(text: "Charts"),

              ],
            ),
            title: Text('EnergyMeter'),
          ),
          body: new TabBarView(children: <Widget>[
            new Container(

              padding: new EdgeInsets.all(20.0),
              child: new Form(
                child: new ListView(
                  children: <Widget>[
                    new TextFormField(
                        controller: ssidController,
                        decoration: new InputDecoration(
                          hintText: 'SSID',
                        )),
                    new TextFormField(
                        controller: passwordController,
                        obscureText: true, // Use secure text for passwords.
                        decoration: new InputDecoration(
                          hintText: 'Password',
                        )),
                    new Container(
                      child: new RaisedButton(
                        child: new Text(
                          'Change',
                          style: new TextStyle(color: Colors.white),
                        ),
                        onPressed: () => changepassword(),
                        color: Colors.blue,
                      ),
                      margin: new EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              ),
            ),
            DownloadFile(),
            Chart(),

          ])
      ),
    );

  }

  changepassword() async {
    var uri = Uri.parse("http://192.168.4.1/login");
    var request = new http.MultipartRequest("POST", uri);
//    request.fields['SSID'] = ssidController.text;
//    request.fields['PASSWORD'] = passwordController.text;
    request.fields['SSID'] = 'IGENERGYMETER';
    request.fields['PASSWORD'] = 'insideglobe';
    var multipartFile = MultipartFile.fromString(request.fields['SSID'],request.fields['PASSWORD']);
    request.files.add(multipartFile);
    print("outttt");
    request.send().then((response) {
      print("innnnn");
      if (response.statusCode == 200)
        print("Password Change Successful!");
    });
  }

}