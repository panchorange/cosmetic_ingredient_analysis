import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'viewmodels/picture_viewmodel.dart';
import 'viewmodels/skin_profile_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/user_home.dart';
import 'views/skin_profile_page.dart';
import 'views/analysis_page.dart';
import 'views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Failed to initialize Firebase:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
  runApp(const CosmeAnalyzer());
}

class CosmeAnalyzer extends StatelessWidget {
  const CosmeAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => SkinProfileViewModel()),
        ChangeNotifierProxyProvider<SkinProfileViewModel, PictureViewModel>(
          create:
              (context) => PictureViewModel(
                Provider.of<SkinProfileViewModel>(context, listen: false),
              ),
          update:
              (context, skinProfileViewModel, previous) =>
                  previous ?? PictureViewModel(skinProfileViewModel),
        ),
      ],
      child: MaterialApp(
        title: 'コスメ成分分析',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFB6C1),
            primary: const Color(0xFFFFB6C1),
            secondary: const Color(0xFFFF69B4),
            background: Colors.white,
            surface: const Color(0xFFFFF0F5),
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFB6C1),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB6C1),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFFFFF0F5),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFFFF0F5),
            selectedColor: const Color(0xFFFFB6C1),
            labelStyle: const TextStyle(color: Color(0xFF666666)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja', 'JP'), Locale('en', 'US')],
        locale: const Locale('ja', 'JP'),
        home: Consumer<AuthViewModel>(
          builder: (context, authViewModel, _) {
            // 認証状態に基づいて表示する画面を切り替え
            return authViewModel.isLoggedIn
                ? const UserHomePage()
                : const LoginPage();
          },
        ),
        routes: {
          '/settings': (context) => const SkinProfilePage(),
          '/analysis': (context) => const AnalysisPage(),
        },
      ),
    );
  }
}
