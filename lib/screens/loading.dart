import 'package:flutter/material.dart';
import 'package:hawa/screens/result.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  setupLoading() async {
    await Future.delayed(Duration(seconds: 2), () {});
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return ResultScreen();
    }));
  }

  @override
  void initState() {
    super.initState();
    setupLoading();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text("Loading..."),
      ),
    );
  }
}
