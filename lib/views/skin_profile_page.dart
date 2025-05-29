import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/skin_profile_viewmodel.dart';
import '../utils/contents/app_colors.dart';
import '../utils/contents/app_spacing.dart';

class SkinProfilePage extends StatefulWidget {
  const SkinProfilePage({super.key});

  @override
  State<SkinProfilePage> createState() => _SkinProfilePageState();
}

class _SkinProfilePageState extends State<SkinProfilePage> {
  // 選択状態を管理する変数
  DateTime? selectedBirthDate = DateTime(1995, 1, 1);
  String? selectedGender = 'female';
  String selectedSkinType = '乾燥';
  final Set<String> selectedSkinProblems = {'ニキビ', 'シミ'};
  final Set<String> selectedAvoidIngredients = {'香料', 'なし'};
  final Set<String> selectedEffects = {'保湿', 'エイジングケア'};
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedProfile();
  }

  Future<void> _loadSavedProfile() async {
    final viewModel = Provider.of<SkinProfileViewModel>(context, listen: false);
    await viewModel.loadProfile();

    if (viewModel.profile != null) {
      setState(() {
        selectedBirthDate = viewModel.profile!.birthDate;
        selectedGender = viewModel.profile!.gender;
        selectedSkinType = viewModel.profile!.skinType;
        selectedSkinProblems.clear();
        selectedSkinProblems.addAll(viewModel.profile!.skinProblems);
        selectedAvoidIngredients.clear();
        selectedAvoidIngredients.addAll(viewModel.profile!.avoidIngredients);
        selectedEffects.clear();
        selectedEffects.addAll(viewModel.profile!.desiredEffects);
        if (viewModel.profile!.note != null) {
          noteController.text = viewModel.profile!.note!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightPink,
        title: const Text(
          '肌プロフィール',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Roboto',
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '誕生日',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedBirthDate = picked;
                      });
                    }
                  },
                  child: Text(
                    selectedBirthDate != null
                        ? '${selectedBirthDate!.year}年${selectedBirthDate!.month}月${selectedBirthDate!.day}日'
                        : '選択してください',
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '性別',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedGender,
                  hint: const Text('選択してください'),
                  dropdownColor: AppColors.lavenderBrush, // ラベンダーブラッシュ
                  style: const TextStyle(
                    color: AppColors.darkSlateGray, // ダークグレー
                    fontSize: 16,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'female', child: Text('女性')),
                    DropdownMenuItem(value: 'male', child: Text('男性')),
                    DropdownMenuItem(value: 'other', child: Text('その他')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '肌タイプ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.itemSpacing,
              children:
                  ['乾燥', '脂性', '混合', '敏感', '普通'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: selectedSkinType == type,
                      onSelected: (selected) {
                        setState(() {
                          selectedSkinType = type;
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '主な肌悩み',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.itemSpacing,
              children:
                  ['ニキビ', '乾燥', 'シミ', 'くすみ', '毛穴', 'しわ/たるみ'].map((problem) {
                    return FilterChip(
                      label: Text(problem),
                      selected: selectedSkinProblems.contains(problem),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedSkinProblems.add(problem);
                          } else if (!selected) {
                            selectedSkinProblems.remove(problem);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '避けたい成分',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.itemSpacing,
              children:
                  ['アルコール', '香料', 'パラベン', '鉱物油', 'シリコン', 'なし'].map((
                    ingredient,
                  ) {
                    return FilterChip(
                      label: Text(ingredient),
                      selected: selectedAvoidIngredients.contains(ingredient),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (ingredient == 'なし') {
                              selectedAvoidIngredients.clear();
                              selectedAvoidIngredients.add('なし');
                            } else {
                              selectedAvoidIngredients.remove('なし');
                              selectedAvoidIngredients.add(ingredient);
                            }
                          } else {
                            selectedAvoidIngredients.remove(ingredient);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '求める効果',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.itemSpacing,
              children:
                  ['保湿', '美白', 'エイジングケア', 'ニキビケア', '毛穴ケア', 'UVケア'].map((
                    effect,
                  ) {
                    return FilterChip(
                      label: Text(effect),
                      selected: selectedEffects.contains(effect),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedEffects.add(effect);
                          } else if (!selected) {
                            selectedEffects.remove(effect);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            const Text(
              '特記事項（任意）',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: noteController,
              maxLines: 3,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: '過去に合わなかった成分など',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hotPink,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                onPressed: () {
                  // ViewModelに保存
                  final viewModel = Provider.of<SkinProfileViewModel>(
                    context,
                    listen: false,
                  );
                  viewModel.saveProfile(
                    birthDate: selectedBirthDate ?? DateTime.now(),
                    gender: selectedGender ?? 'other',
                    skinType: selectedSkinType,
                    skinProblems: selectedSkinProblems,
                    avoidIngredients: selectedAvoidIngredients,
                    desiredEffects: selectedEffects,
                    note:
                        noteController.text.isEmpty
                            ? null
                            : noteController.text,
                  );

                  // ホーム画面に戻る
                  Navigator.pop(context);
                },
                child: const Text(
                  '保存する',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
