import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Rally3DTributeApp());
}

class Rally3DTributeApp extends StatelessWidget {
  const Rally3DTributeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rally 3D AI Tribute',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // పాత రెట్రో డార్క్ థీమ్
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
