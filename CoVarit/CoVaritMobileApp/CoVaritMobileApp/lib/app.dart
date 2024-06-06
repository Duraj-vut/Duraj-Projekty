import 'package:flutter/material.dart';
import 'package:test/main.dart';
import 'config.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      darkTheme: ThemeData.dark(),
      themeMode: currentTheme.currentTheme(),
      home: TabBarDemo(),
    );
  }
}
