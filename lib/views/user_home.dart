import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/picture_viewmodel.dart';
import '../viewmodels/skin_profile_viewmodel.dart';
import '../utils/contents/app_colors.dart';
import '../utils/contents/app_spacing.dart';
import 'package:flutter/foundation.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPink, // ライトピンク
        title: const Text(
          'コスメ成分分析',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Roboto',
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<PictureViewModel, SkinProfileViewModel>(
        builder: (context, pictureViewModel, skinProfileViewModel, child) {
          // プロフィール情報が存在する場合、PictureViewModelに設定
          if (skinProfileViewModel.profile != null &&
              pictureViewModel.currentProfile == null) {
            pictureViewModel.setProfile(skinProfileViewModel.profile!);
            debugPrint('プロフィール情報をPictureViewModelに設定しました');
          }

          return SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSpacing.contentMargin,
                    ),
                    padding: EdgeInsets.all(AppSpacing.defaultPadding),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderBrush, // ラベンダーブラッシュ
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '✨ はじめましょう ✨',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateGray,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '1. あなたの肌の特徴を教えてね👩',
                          style: TextStyle(
                            color: AppColors.darkSlateGray,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '2. お気に入りのコスメ画像をアップロード⭐️',
                          style: TextStyle(
                            color: AppColors.darkSlateGray,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '3. あなたへ分析結果をお届け📈',
                          style: TextStyle(
                            color: AppColors.darkSlateGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // 画像表示部分 - WebとMobileの両方に対応
                  if ((kIsWeb && pictureViewModel.selectedImageBytes != null) ||
                      (!kIsWeb && pictureViewModel.selectedImage != null))
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                        child:
                            kIsWeb
                                ? Image.memory(
                                  pictureViewModel.selectedImageBytes!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('画像の読み込みに失敗しました'),
                                    );
                                  },
                                )
                                : Image.file(
                                  pictureViewModel.selectedImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('画像の読み込みに失敗しました'),
                                    );
                                  },
                                ),
                      ),
                    )
                  else
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(AppSpacing.sm),
                      ),
                      child: const Center(child: Text('画像が選択されていません')),
                    ),

                  SizedBox(height: AppSpacing.md),

                  // ファイル選択ボタン
                  ElevatedButton.icon(
                    onPressed: pictureViewModel.pickFromGallery,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('ファイルを選択'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      backgroundColor: AppColors.lightPink,
                      foregroundColor: Colors.white,
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // バーコード手動入力フィールド
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSpacing.contentMargin,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'バーコード（任意入力）',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkSlateGray,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _barcodeController,
                                decoration: const InputDecoration(
                                  hintText: 'バーコードを入力（例: 4987241188833）',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            ElevatedButton(
                              onPressed: () async {
                                await pictureViewModel.setManualBarcode(
                                  _barcodeController.text,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightPink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('設定'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // バーコード結果表示
                  if (pictureViewModel.barcodeResult != null)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppSpacing.contentMargin,
                      ).copyWith(top: AppSpacing.md),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderBrush,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '✅ バーコード: ${pictureViewModel.barcodeResult}',
                        style: const TextStyle(
                          color: AppColors.darkSlateGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // アップロードボタン（撮影完了後に表示）
                  if ((kIsWeb && pictureViewModel.selectedImageBytes != null) ||
                      (!kIsWeb && pictureViewModel.selectedImage != null))
                    ElevatedButton.icon(
                      onPressed:
                          pictureViewModel.isLoading
                              ? null
                              : pictureViewModel.uploadAndAnalyze,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('アップロードして解析'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        backgroundColor: const Color(0xFFFF69B4),
                        foregroundColor: Colors.white,
                      ),
                    ),

                  if (pictureViewModel.isLoading)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.sm),
                        const Text('処理中...'),
                      ],
                    ),

                  if (pictureViewModel.resultText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppSpacing.contentMargin,
                      ),
                      padding: EdgeInsets.all(AppSpacing.defaultPadding),
                      decoration: BoxDecoration(
                        color:
                            pictureViewModel.resultText.contains('エラー') ||
                                    pictureViewModel.resultText.contains('失敗')
                                ? const Color(0xFFFFEBEE) // エラーの場合は薄い赤背景
                                : const Color(0xFFFFF0F5), // 成功の場合は薄いピンク背景
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                            pictureViewModel.resultText.contains('エラー') ||
                                    pictureViewModel.resultText.contains('失敗')
                                ? Border.all(
                                  color: const Color(0xFFE57373),
                                  width: 1.0,
                                )
                                : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pictureViewModel.resultText.contains('エラー') ||
                              pictureViewModel.resultText.contains('失敗'))
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFD32F2F),
                              size: 20,
                            )
                          else
                            const Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF388E3C),
                              size: 20,
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pictureViewModel.resultText,
                              style: const TextStyle(
                                color: AppColors.darkSlateGray,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: '分析',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/analysis');
          }
        },
      ),
    );
  }
}
