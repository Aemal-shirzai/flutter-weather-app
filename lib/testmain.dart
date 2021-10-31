import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  Future<http.Response> data;
  Future<http.Response> _getData() async {
    print("hello and welcome");
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/1'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Faild Due to ${response.statusCode}');
    }
    print("-----------------------");
  }

  @override
  void initState() {
    // TODO: implement initState
    data = _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(12),
                color: Colors.lightBlue,
                child: FutureBuilder<http.Response>(
                  future: data,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print("========== ${snapshot.data}");

                      return Text('hello sir');
                    }
                    // else {
                    //   return Text("No Data yet");
                    // }
                    return Text(snapshot.toString());
                  },
                ))
          ],
        ),
      ),
    );
  }
}
