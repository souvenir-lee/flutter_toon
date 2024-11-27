import 'package:flutter/material.dart';
import 'package:flutter_toon/screens/home_screen.dart';
import 'package:flutter_toon/services/api_services.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
