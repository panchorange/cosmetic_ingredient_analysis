import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skin_profile.dart';
import '../utils/contents/app_colors.dart';

class SkinProfileViewModel extends ChangeNotifier {
    SkinProfile? _profile;
    static const String _profileKey = 'skin_profile';

    // ゲッター
    SkinProfile? get profile => _profile;

    // 初期化時に保存されたデータを読み込む
    Future<void> loadProfile() async {
        final prefs = await SharedPreferences.getInstance();
        final profileJson = prefs.getString(_profileKey);
        if (profileJson != null) {
            final Map<String, dynamic> profileMap = json.decode(profileJson);
            _profile = SkinProfile(
                birthDate: DateTime.parse(profileMap['birthDate']),
                gender: profileMap['gender'],
                skinType: profileMap['skinType'],
                skinProblems: Set<String>.from(profileMap['skinProblems']),
                avoidIngredients: Set<String>.from(profileMap['avoidIngredients']),
                desiredEffects: Set<String>.from(profileMap['desiredEffects']),
                note: profileMap['note'],
            );
            notifyListeners();
        }
    }

    // プロフィールの保存
    Future<void> saveProfile({
        required DateTime birthDate,
        required String gender,
        required String skinType,
        required Set<String> skinProblems,
        required Set<String> avoidIngredients,
        required Set<String> desiredEffects,
        String? note,
    }) async {
        _profile = SkinProfile(
            birthDate: birthDate,
            gender: gender,
            skinType: skinType,
            skinProblems: skinProblems,
            avoidIngredients: avoidIngredients,
            desiredEffects: desiredEffects,
            note: note,
        );

        // SharedPreferencesに保存
        final prefs = await SharedPreferences.getInstance();
        final profileMap = {
            'birthDate': birthDate.toIso8601String(),
            'gender': gender,
            'skinType': skinType,
            'skinProblems': skinProblems.toList(),
            'avoidIngredients': avoidIngredients.toList(),
            'desiredEffects': desiredEffects.toList(),
            'note': note,
        };
        await prefs.setString(_profileKey, json.encode(profileMap));
        notifyListeners();
    }

    // プロフィールのクリア
    Future<void> clearProfile() async {
        _profile = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_profileKey);
        notifyListeners();
    }
} 