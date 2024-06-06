// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, non_constant_identifier_names
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:test/app.dart';
import 'package:test/recipe.dart';
import 'dart:convert';
import 'package:test/results.dart';
import 'package:test/settings.dart';

List<Recipe> responseRecipes = [];
int number = 0;
List<List> arrFinalIngrediences = [];
List<String> arrIngrediences = [];
bool isSwitched = false;

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class TabBarDemo extends StatefulWidget {
  @override
  _TabBarDemoState createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<TabBarDemo> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return (DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Čo variť'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Nájsť recept'),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //tab1
            Container(
              child: Vyhladavanie(),
            ),

            //tab2
            Container(
              child: Nastavenia(),
            ),
          ],
        ),
      ),
    ));
  }
}

//tab1 Vyhladavanie
class Vyhladavanie extends StatefulWidget {
  const Vyhladavanie({super.key});

  @override
  State<Vyhladavanie> createState() => _VyhladavanieState();
}

class _VyhladavanieState extends State<Vyhladavanie> {
  String serverResponse = '';
  var status = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 200,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            //formular
            Container(
              child: Form(),
            ),

            ElevatedButton(
              onPressed: status
                  ? () async {
                      status = !status;
                      responseRecipes = [];

                      if ((dropdownValue[0] != 'Vyber surovinu') ||
                          (dropdownValue[1] != 'Vyber surovinu') ||
                          (dropdownValue[2] != 'Vyber surovinu') ||
                          (dropdownValue[3] != 'Vyber surovinu')) {
                        _PostForm();
                        await Future.delayed(const Duration(seconds: 1), () {});
                        await _getNum();
                        await _serverResponseValue();
                        for (var i = 0; i < number; i++) {
                          await _GetResults();
                        }
                        await Future.delayed(const Duration(seconds: 1), () {});
                        await _resetServerResponseValue();
                        await _toIngrediences();
                        status = !status;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Results()),
                        );
                      } else {
                        status = !status;
                        setState(() {
                          serverResponse = ("Musíte vyplniť aspoň jedno okno");
                        });
                      }
                    }
                  : null,
              child: Text('Hľadať'),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(serverResponse),
            ),
          ]),
        ),
      ),
    );
  }

  _serverResponseValue() async {
    setState(() {
      if (number == 1) {
        serverResponse = ("Načítava sa ") + number.toString() + (" recept");
      } else if (number > 1 && number < 5) {
        serverResponse = ("Načítavajú sa ") + number.toString() + (" recepty");
      } else {
        serverResponse = ("Načítava sa ") + number.toString() + (" receptov");
      }
    });
  }

  _resetServerResponseValue() async {
    setState(() {
      serverResponse = "";
    });
  }

  _PostForm() async {
    final urlSearch =
        Uri.parse('https://1468-81-161-61-217.eu.ngrok.io/mobileapp/search');

    post(
      urlSearch,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ingredience0': dropdownValue[0],
        'ingredience1': dropdownValue[1],
        'ingredience2': dropdownValue[2],
        'ingredience3': dropdownValue[3],
      }),
    );
  }
}

_GetResults() async {
  final urlGetdata =
      Uri.parse('https://1468-81-161-61-217.eu.ngrok.io/mobileapp/getdata');

  Response httpResponse = await http.get(urlGetdata);
  final parsedResults = jsonDecode(httpResponse.body);

  final recipe = Recipe.fromJson(parsedResults);
  responseRecipes.add(recipe);

}

_getNum() async {
  final urlGetnum =
      Uri.parse('https://1468-81-161-61-217.eu.ngrok.io/mobileapp/getnum');

  Response httpNum = await http.get(urlGetnum);
  final resNum = jsonDecode(httpNum.body);
  number = (resNum['number']);
}

_toIngrediences() async {
  arrIngrediences = [];

  for (var i = 0; i < number; i++) {
    String ingString = "";
    var allIng = (responseRecipes[i].ingrediences);
    var jsonIngrediences = jsonDecode(allIng);
    //na json

    for (var j = 0; j < responseRecipes[i].numOfIng; j++) {
      final jsonResponse = (jsonIngrediences['ingredience$j']);
      if (jsonResponse != null) {
        ingString = ingString + ("\n $jsonResponse");
      } else {
        break;
      }


    }

    arrIngrediences.add(ingString);
  }
}

//formular
List dropdownValue = [list.first, list.first, list.first, list.first];
List<String> list = <String>[
  'Vyber surovinu',
  'avokádo',
  'bazalka',
  'biela kapusta',
  'biely jogurt',
  'bravčové stehno',
  'čaj',
  'cesnak',
  'chlieb',
  'cibuľa',
  'cukor',
  'droždie',
  'hladká múka',
  'horčica',
  'hovädzí bujón',
  'jablko',
  'káva',
  'kečup',
  'korenie',
  'kuracie prsia',
  'kuracie stehno',
  'kyslá smotana',
  'maslo',
  'mlieko',
  'mrazená zelenina',
  'olej',
  'paradajkový pretlak',
  'petržlenová vňať',
  'škorica',
  'šľahačková smotana',
  'slanina',
  'slepačí bujón',
  'smotana na varenie',
  'sóda bikarbóna',
  'soľ',
  'sušené huby',
  'syr',
  'vajce',
  'voda',
  'zemiak'
];

class Form extends StatefulWidget {
  const Form({super.key});

  @override
  State<Form> createState() => _FormState();
}

class _FormState extends State<Form> {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(child: Text("Zadajte suroviny")),
      Container(
          child: DropdownButton<String>(
        value: dropdownValue[0],
        icon: const Icon(Icons.arrow_downward),
        onChanged: (String? value) {
          setState(() {
            dropdownValue[0] = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )),
      Container(
          child: DropdownButton<String>(
        value: dropdownValue[1],
        icon: const Icon(Icons.arrow_downward),
        onChanged: (String? value) {
          setState(() {
            dropdownValue[1] = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )),
      Container(
          child: DropdownButton<String>(
        value: dropdownValue[2],
        icon: const Icon(Icons.arrow_downward),
        onChanged: (String? value) {
          setState(() {
            dropdownValue[2] = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )),
      Container(
          child: DropdownButton<String>(
        value: dropdownValue[3],
        icon: const Icon(Icons.arrow_downward),
        onChanged: (String? value) {
          setState(() {
            dropdownValue[3] = value!;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )),
    ]);
  }
}
