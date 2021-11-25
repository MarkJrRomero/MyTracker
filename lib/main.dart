import 'package:flutter/material.dart';
import 'package:mytracker/page/HomePage.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Tracker",
      home: MyHomePage(),
    );
  }
}

