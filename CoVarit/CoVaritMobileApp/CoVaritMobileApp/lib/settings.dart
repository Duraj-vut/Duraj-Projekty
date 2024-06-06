// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors
//tab2 Nastavenia
import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

class Nastavenia extends StatefulWidget {
  const Nastavenia({super.key});

  @override
  State<Nastavenia> createState() => _NastaveniaState();
}

class _NastaveniaState extends State<Nastavenia> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(children: [
          Text(
              style: const TextStyle(fontWeight: FontWeight.bold),
              "Farebná schéma"),
          Padding(
            padding: EdgeInsets.all(16.0),
          ),
          Text("Tmavý mód"),
          Switch(
              value: isSwitched,
              onChanged: (value) {
                currentTheme.switchTheme();
                setState(() {
                  isSwitched = value;
                });
              }),
        ]),
      )),
    );
  }
}
