import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RiveAnimation.network(
        'https://cdn-v4-cms.mypossibleself.com/anxiety_banner_lightmode_test_3_1_615bc73c61.riv',
        fit: BoxFit.none,
        placeHolder: Center(child: SizedBox()),
      ),
    );
  }
}







