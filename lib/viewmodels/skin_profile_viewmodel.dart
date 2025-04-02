import 'package:flutter/foundation.dart';
import '../models/skin_profile.dart';

class SkinProfileViewModel extends ChangeNotifier {
    SkinProfile? _profile;

    // ゲッター
    SkinProfile? get profile => _profile;

    // プロフィールの保存
    void saveProfile({
        required String skinType,
        required Set<String> skinProblems,
        required Set<String> avoidIngredients,
        required Set<String> desiredEffects,
        String? note,
    }) {
        _profile = SkinProfile(
            skinType: skinType,
            skinProblems: skinProblems,
            avoidIngredients: avoidIngredients,
            desiredEffects: desiredEffects,
            note: note,
        );
        notifyListeners();
    }

    // プロフィールのクリア
    void clearProfile() {
        _profile = null;
        notifyListeners();
    }
} 