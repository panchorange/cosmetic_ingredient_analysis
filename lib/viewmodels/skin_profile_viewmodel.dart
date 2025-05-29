import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skin_profile.dart';

/// 肌プロフィール情報の永続化と状態管理を行うViewModel
///
/// 以下の機能を提供
/// - プロフィール情報の保存と読み込み
/// - プロフィール情報の状態管理
/// - プロフィール情報のクリア
class SkinProfileViewModel extends ChangeNotifier {
  /// 現在のプロフィール情報
  SkinProfile? _profile;

  /// SharedPreferencesに保存する際のキー
  static const String _profileKey = 'skin_profile';

  /// 現在のプロフィール情報を取得
  ///
  /// 戻り値:
  /// - プロフィールが存在する場合: SkinProfileインスタンス
  /// - プロフィールが存在しない場合: null
  SkinProfile? get profile => _profile;

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

  /// プロフィール情報を保存
  ///
  /// 指定された情報で新しい[SkinProfile]インスタンスを作成し、
  /// SharedPreferencesに永続化します。
  ///
  /// パラメータ:
  /// - [birthDate]: 生年月日
  /// - [gender]: 性別
  /// - [skinType]: 肌タイプ
  /// - [skinProblems]: 肌の悩み
  /// - [avoidIngredients]: 避けたい成分
  /// - [desiredEffects]: 求める効果
  /// - [note]: 特記事項（任意）
  ///
  /// 保存が完了すると、リスナーに通知されます。
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
