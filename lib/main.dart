import 'package:flutter/material.dart';
import 'package:hawa/screens/loading.dart';

void main() => runApp(HawaApp());

class HawaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Comfortaa-Regular',
        textTheme: TextTheme(
          headline1: TextStyle(color: Colors.white, fontSize: 160, letterSpacing: 1.5),
          headline4: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.5, fontWeight: FontWeight.bold),
          headline5: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.5),
          headline6: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1),
        ),
      ),
      home: Scaffold(
          body: SafeArea(
          child: LoadingScreen(),
        ),
      ),
    );
  }
}
