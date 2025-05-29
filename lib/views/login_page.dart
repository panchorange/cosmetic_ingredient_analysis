import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'user_home.dart';
import '../utils/contents/app_colors.dart';
import '../utils/contents/app_spacing.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, _) {
          // ログイン済みの場合はホーム画面に移動
          if (authViewModel.isLoggedIn) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const UserHomePage()),
              );
            });
          }

          return Container(
            padding: EdgeInsets.all(AppSpacing.defaultPadding),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF0F5), Colors.white],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // アプリロゴやイメージ
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // アプリタイトル
                      const Text(
                        'コスメ成分分析',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.hotPink,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // アプリ説明
                      const Text(
                        '化粧品の成分を分析して、あなたに合った製品を見つけましょう',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 48),

                      // Googleログインボタン
                      SizedBox(height: AppSpacing.xl),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.defaultPadding),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppSpacing.md),
                        ),
                        child: Column(
                          children: [
                            if (authViewModel.isLoading)
                              Padding(
                                padding: EdgeInsets.only(top: AppSpacing.md),
                                child: const CircularProgressIndicator(),
                              ),
                            if (authViewModel.isLoading)
                              const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: Image.network(
                                'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                                width: 24,
                                height: 24,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                child: Text(
                                  'Googleでログイン',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.md,
                                ),
                              ),
                              onPressed: () async {
                                final success =
                                    await authViewModel.signInWithGoogle();
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        authViewModel.errorMessage ??
                                            'ログインに失敗しました',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            ),
                            if (authViewModel.errorMessage != null)
                              Padding(
                                padding: EdgeInsets.only(top: AppSpacing.md),
                                child: Text(
                                  authViewModel.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // プライバシーポリシーなど
                      const Text(
                        'ログインすることで、利用規約とプライバシーポリシーに同意したことになります。',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
