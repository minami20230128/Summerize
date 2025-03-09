import 'package:flutter/material.dart';
import 'package:summarize_app/screens/BookScreen.dart';

void main() async {
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BookScreen(),
        );
    }
}

