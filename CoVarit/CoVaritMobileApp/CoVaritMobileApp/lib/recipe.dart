import 'dart:convert';

class Recipe {
  Recipe(
      {required this.name,
      required this.process,
      required this.ingrediences,
      required this.numOfIng});
  final String name;
  final String process;
  final String ingrediences;
  final int numOfIng;

  factory Recipe.fromJson(Map<String, dynamic> data) {
    final name = data['name'] as String;
    final process = data['process'] as String;
    final ingrediences = jsonEncode(data['ingrediences']);
    final numOfIng = data['numOfIng'];
    return Recipe(
        name: name,
        process: process,
        ingrediences: ingrediences,
        numOfIng: numOfIng);
  }
}

class Ingredience {
  Ingredience({required this.name, required this.amount, required this.unit});
  final String name;
  final String amount;
  final String unit;

  factory Ingredience.fromJson(Map<String, dynamic> data) {
    final name = data['name'] as String;
    final amount = data['amount'] as String;
    final unit = data['unit'] as String;
    return Ingredience(name: name, amount: amount, unit: unit);
  }
}
