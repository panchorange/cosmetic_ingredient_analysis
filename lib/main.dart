import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/picture_viewmodel.dart';
import 'viewmodels/skin_profile_viewmodel.dart';
import 'views/user_home.dart';
import 'views/skin_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CosmeAnalyzer());
}

class CosmeAnalyzer extends StatelessWidget {
  const CosmeAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PictureViewModel()),
        ChangeNotifierProvider(create: (context) => SkinProfileViewModel()),
      ],
      child: MaterialApp(
        title: 'コスメ成分分析',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // アプリ全体のテーマ設定
        ),
        initialRoute: '/',
        routes: { // ルーティング設定
          '/': (context) => const UserHomePage(),
          '/settings': (context) => const SkinProfilePage(),
        },
        
      ),
    );
  }
}