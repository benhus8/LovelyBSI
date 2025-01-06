import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/my_home_page.dart';
import 'widgets/my_home_page.dart'; // Zmień ścieżkę na właściwą, jeśli plik `MyHomePage` jest w innym miejscu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'I♡BSI'), // Przekazujemy tytuł
    );
  }
}
