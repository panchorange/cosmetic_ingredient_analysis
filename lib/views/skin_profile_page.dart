import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/skin_profile_viewmodel.dart';

class SkinProfilePage extends StatefulWidget {
    const SkinProfilePage({super.key});

    @override
    State<SkinProfilePage> createState() => _SkinProfilePageState();
}

class _SkinProfilePageState extends State<SkinProfilePage> {
    // 選択状態を管理する変数
    String selectedSkinType = '乾燥';
    final Set<String> selectedSkinProblems = {'ニキビ', 'シミ'};
    final Set<String> selectedAvoidIngredients = {'香料', 'なし'};
    final Set<String> selectedEffects = {'保湿', 'エイジングケア'};
    final TextEditingController noteController = TextEditingController();

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.blue,
                title: const Text(
                    'あなたの肌プロフィール',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        letterSpacing: 2.0
                    )
                ),
                centerTitle: true,
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const Text('肌タイプ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            children: ['乾燥', '脂性', '混合', '敏感' ,'普通'].map((type) {
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
                        const SizedBox(height: 24),

                        const Text('主な肌悩み', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            children: ['ニキビ', '乾燥', 'シミ', 'くすみ', '毛穴', 'しわ/たるみ'].map((problem) {
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
                        const SizedBox(height: 24),

                        const Text('避けたい成分', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            children: ['アルコール', '香料', 'パラベン', '鉱物油', 'シリコン', 'なし'].map((ingredient) {
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
                        const SizedBox(height: 24),

                        const Text('求める効果', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                            spacing: 8,
                            children: ['保湿', '美白', 'エイジングケア', 'ニキビケア', '毛穴ケア', 'UVケア'].map((effect) {
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
                        const SizedBox(height: 24),

                        const Text('特記事項（任意）', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                            controller: noteController,
                            maxLines: 3,
                            maxLength: 100,
                            decoration: const InputDecoration(
                                hintText: '過去に合わなかった成分など',
                                border: OutlineInputBorder(),
                            ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[200],
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                    // ViewModelに保存
                                    final viewModel = Provider.of<SkinProfileViewModel>(context, listen: false);
                                    viewModel.saveProfile(
                                        skinType: selectedSkinType,
                                        skinProblems: selectedSkinProblems,
                                        avoidIngredients: selectedAvoidIngredients,
                                        desiredEffects: selectedEffects,
                                        note: noteController.text.isEmpty ? null : noteController.text,
                                    );
                                    
                                    // 保存された内容を確認
                                    print('=== 保存されたプロフィール ===');
                                    print('肌タイプ: $selectedSkinType');
                                    print('主な肌悩み: $selectedSkinProblems');
                                    print('避けたい成分: $selectedAvoidIngredients');
                                    print('求める効果: $selectedEffects');
                                    print('特記事項: ${noteController.text}');
                                    print('==========================');
                                    
                                    // ホーム画面に戻る
                                    Navigator.pop(context);
                                },
                                child: const Text(
                                    '保存する',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                    ),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
} 