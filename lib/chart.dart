import 'package:flutter/material.dart';
import "package:dart_amqp/dart_amqp.dart";
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';

class TimeSeriesPrice {
  final DateTime time;
  final double price;

  TimeSeriesPrice(this.time, this.price);
}

class Chart extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<Chart> {
  var s;

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() {
    return new _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller;
  var s;
  Widget listViewHolder;
  Widget chartViewHolder;

  List<String> items = new List();

  ScrollController _scrollController = new ScrollController();

  List chartdata = List();
  List<TimeSeriesPrice> vData;
  List<TimeSeriesPrice> pfData;
  List<TimeSeriesPrice> iData;
  List<TimeSeriesPrice> apData;
  List<TimeSeriesPrice> rpData;
  String datatodisplay = 'RP';
  @override
  void initState() {
    super.initState();
    connectToAmqp();

    rpData = new List();
    apData = new List();
    iData = new List();
    pfData = new List();
    vData = new List();

    listViewHolder = Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      SizedBox(
        height: 48.0,
      ),
      Text("Connecting..."),
      SizedBox(
        height: 48.0,
      ),
      LinearProgressIndicator()
    ]);
    chartViewHolder = Container();
  }

  void connectToAmqp() async {
    ConnectionSettings settings = new ConnectionSettings(
        host: "ec2-13-232-154-79.ap-south-1.compute.amazonaws.com", port: 8181);
    Client client = new Client(settings: settings);

    client
        .channel()
        .then((Channel channel) =>
        channel.exchange("energymeter", ExchangeType.FANOUT, durable: true))
        .then((Exchange exchange) => exchange.bindPrivateQueueConsumer(null))
        .then((Consumer consumer) {
      print(
          " [*] Waiting for energymeter on private queue ${consumer.queue.name}. To exit, press CTRL+C");
      consumer.listen((AmqpMessage message) {
        print(" [x] ${message.payloadAsString}");
        items.add(message.payloadAsString);
        buildListView();
      });
    });
  }

  void buildListView() {
    List<Widget> listtiles = List<ListTile>();

    for (String t in items) {
      listtiles.add(ListTile(
        title: Text(t),
        leading: Icon(Icons.lightbulb_outline),
      ));

      Map json = jsonDecode(t);
      if (json.containsKey("RP")) {
        if (rpData.length > 25) {
          rpData.removeAt(0);
          apData.removeAt(0);
          iData.removeAt(0);
          pfData.removeAt(0);
          vData.removeAt(0);
        }

        print(rpData.length);
        DateTime dateTime = DateTime.parse(json['ts']['\$date']);
        DateTime dateT = dateTime;
        rpData.add(TimeSeriesPrice(dateT, json['RP']));
        apData.add(TimeSeriesPrice(dateT, json['AP']));
        iData.add(TimeSeriesPrice(dateT, json['I'] * 1));
        pfData.add(TimeSeriesPrice(dateT, json['PF']));
        vData.add(TimeSeriesPrice(dateT, json['V']));
        rpData.forEach((t) {
          print(t.time);
        });
      }
    }

    setState(() {
      listViewHolder = ListView(
        controller: _scrollController,
        shrinkWrap: true,
        children: listtiles,
      );
    });

    switch (datatodisplay) {
      case "RP":
        createChartView(rpData);
        break;
      case "AP":
        createChartView(apData);
        break;
      case "PF":
        createChartView(pfData);
        break;
      case "V":
        createChartView(vData);
        break;
      case "I":
        createChartView(iData);
        break;
    }
//todo use this scroll controller object to scroll to last the while the user press the goto last FAB
    if (items.length > 5) {
//      scrollToEnd();
    }
  }

  getRowButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            onPressed: () {

              createChartView(rpData);
              datatodisplay = "RP";
            },
            child: Text("RP"),
            color: Colors.transparent,
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {

              createChartView(apData);
              datatodisplay = "AP";

            },
            child: Text("AP"),
            color: Colors.transparent,
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {

              createChartView(iData);
              datatodisplay = "I";
            },
            child: Text("I"),
            color: Colors.transparent,
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {

              createChartView(pfData);
              datatodisplay = "PF";
            },
            child: Text("PF"),
            color: Colors.transparent,
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {

              createChartView(vData);
              datatodisplay = "V";
            },
            child: Text("V"),
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  void createChartView(List<TimeSeriesPrice> data) {
    setState(() {
      //time series sales dialog
      chartViewHolder = new charts.TimeSeriesChart(
        [
          new charts.Series<TimeSeriesPrice, DateTime>(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (TimeSeriesPrice sales, _o) => sales.time,
            measureFn: (TimeSeriesPrice sales, _) => sales.price,
            data: data,
          ),
        ],
        animate: false,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        animationDuration: Duration(seconds: 2),
        behaviors: [
          charts.PanAndZoomBehavior(),
        ],
      );
    });
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      s();
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: chartViewHolder,
          ),
          getRowButtons(),
        ],
      ),
    );
  }
}