import 'package:flutter/material.dart';
import 'package:modular_yoga_session_app/providers/session_provider.dart';
import 'package:modular_yoga_session_app/screens/session_screen.dart' ;
import 'package:provider/provider.dart';

void main() {
  runApp(const YogaApp());

}

class YogaApp extends StatelessWidget {
  const YogaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        title: 'Modular Yoga Session App',
        debugShowCheckedModeBanner: false,
        home: PoseSessionScreen(),
    ),
    );
  }
}
