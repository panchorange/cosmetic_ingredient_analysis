import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/picture_viewmodel.dart';
import 'viewmodels/skin_profile_viewmodel.dart';
import 'views/user_home.dart';
import 'views/skin_profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Failed to initialize Firebase:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    // Firebaseの初期化に失敗してもアプリは起動する
  }
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Builder(
          builder: (context) {
            return const UserHomePage();
          },
        ),
        routes: {
          '/settings': (context) => const SkinProfilePage(),
        },
      ),
    );
  }
}