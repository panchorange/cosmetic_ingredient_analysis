import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/picture_viewmodel.dart';
import '../utils/contents/app_colors.dart';
import '../utils/contents/app_spacing.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _hasShownPopup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPink,
        title: const Text(
          '分析結果',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Roboto',
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PictureViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.analysisResult != null && !_hasShownPopup) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showNewResultPopup(context);
              setState(() {
                _hasShownPopup = true;
              });
            });
          }

          if (viewModel.analysisResult == null) {
            return const Center(
              child: Text('分析結果がありません', style: TextStyle(fontSize: 18)),
            );
          }

          final analysis = viewModel.analysisResult!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  padding: EdgeInsets.all(AppSpacing.defaultPadding),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderBrush,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '製品名: ${analysis['product_name'] ?? "製品名なし"}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),

                      Text(
                        '総合評価: ${analysis["overall_score"] ?? "総合評価(数値)の値がありません"} / 5',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: AppColors.lavenderBrush, // ラベンダーブラッシュ
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            analysis['overall_assessment'] ??
                                "総合評価(説明文)の値がありません",
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '成分分析:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List<Widget>.from(
                        (analysis['ingredients'] as List).map((ingredient) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ingredient['name'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      _buildRatingChip(ingredient['rating']),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ingredient['effect'],
                                    style: const TextStyle(fontSize: 16),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingChip(String rating) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (rating) {
      case '良好':
        backgroundColor = AppColors.paleGreen; // ペールグリーン
        textColor = AppColors.darkSlateGray; // ダークスレートグレー
        break;
      case 'やや注意':
        backgroundColor = AppColors.lightPink; // ライトピンク
        textColor = AppColors.darkSlateGray; // ダークスレートグレー
        break;
      case '注意':
        backgroundColor = AppColors.hotPink; // ホットピンク
        break;
      default:
        backgroundColor = AppColors.lightGray; // ライトグレー
        textColor = AppColors.darkSlateGray; // ダークスレートグレー
    }

    return Chip(
      label: Text(rating, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
    );
  }

  void _showNewResultPopup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('新しい分析結果が届きました！'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
