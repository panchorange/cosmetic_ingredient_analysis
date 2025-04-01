import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/picture_viewmodel.dart';
import 'views/user_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CosmeAnalyzer());
}

class CosmeAnalyzer extends StatelessWidget {
  const CosmeAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PictureViewModel(),
      child: MaterialApp(
        title: 'コスメ成分分析',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const UserHomePage(),
      ),
    );
  }
}