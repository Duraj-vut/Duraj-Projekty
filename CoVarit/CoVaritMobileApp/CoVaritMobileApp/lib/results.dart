import 'package:flutter/material.dart';
import 'package:test/main.dart';
import 'config.dart';

class Results extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  Results({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      darkTheme: ThemeData.dark(),
      themeMode: currentTheme.currentTheme(),
      home: Scaffold(
        body: Center(
          child: Scrollbar(
            controller: _scrollController,
            child: ListView.builder(
                controller: _scrollController,
                itemCount: number,
                itemBuilder: (context, index) {
                  return Card(
                      child: Column(
                    children: [
                      ListTile(
                        title: Text(
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            "Recept: ${responseRecipes[index].name}"),
                        tileColor: const Color.fromARGB(255, 161, 100, 7),
                      ),
                      ListTile(
                        title: Text(
                            style: const TextStyle(fontWeight: FontWeight.w500),
                            "Zoznam ingrediencii:${arrIngrediences[index]} "),
                      ),
                      ListTile(
                        title: Text(responseRecipes[index].process),
                      )
                    ],
                  ));
                }),
          ),
        ),
      ),
    );
  }
}
