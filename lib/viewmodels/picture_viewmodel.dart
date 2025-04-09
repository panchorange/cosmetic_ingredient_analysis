import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/skin_profile.dart';
import 'dart:convert';

class PictureViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _resultText = '';
  File? _selectedImage;
  String? _uploadedImageUrl;
  SkinProfile? _currentProfile;
  Map<String, dynamic>? _analysisResult;

  // Getters
  bool get isLoading => _isLoading;
  String get resultText => _resultText;
  File? get selectedImage => _selectedImage;
  String? get uploadedImageUrl => _uploadedImageUrl;
  SkinProfile? get currentProfile => _currentProfile;
  Map<String, dynamic>? get analysisResult => _analysisResult;

  // プロフィール情報を設定
  void setProfile(SkinProfile profile) {
    _currentProfile = profile;
    print('プロフィール設定: ${profile.toJson()}');
    notifyListeners();
  }

  // 画像を撮影するメソッド
  Future<void> takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    processSelectedImage(photo);
  }

  // ギャラリーから画像を選択するメソッド
  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    processSelectedImage(image);
  }

  // 画像の処理を行うメソッド
  void processSelectedImage(XFile? imageFile) {
    if (imageFile != null) {
      _selectedImage = File(imageFile.path);
      _isLoading = false;
      _resultText = '';
      _uploadedImageUrl = null;
      notifyListeners();
    }
  }

  // Firebase Storageにアップロードするメソッド
  Future<String> _uploadImageToFirebase(File imageFile, String folderName) async {
    print('画像アップロード開始: フォルダ名=$folderName');
    final storageRef = FirebaseStorage.instance.ref();
    // フォルダ構造を作成するためにフォルダ名とファイル名を分けて指定
    final cosmesRef = storageRef.child('cosmes').child(folderName).child('image.jpg');
    print('アップロード先パス: ${cosmesRef.fullPath}');

    final uploadTask = cosmesRef.putFile(
      imageFile,
      SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded_by': 'app'}
      )
    );

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      print('アップロード進行状況: $progress%');
    });

    await uploadTask.whenComplete(() => print('画像アップロード完了: ${cosmesRef.fullPath}'));
    final downloadUrl = await cosmesRef.getDownloadURL();
    return downloadUrl;
  }

  // プロフィール情報をテキストファイルとしてアップロード
  Future<void> _uploadProfileToFirebase(String folderName) async {
    print('_uploadProfileToFirebase called with folderName: $folderName');
    if (_currentProfile == null) {
      print('プロフィール情報が null です');
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref();
      // フォルダ構造を作成するためにフォルダ名とファイル名を分けて指定
      final profileRef = storageRef.child('cosmes').child(folderName).child('profile.txt');

      // プロフィール情報をテキスト形式に変換
      String profileText = '''
      肌タイプ: ${_currentProfile!.skinType}
      肌悩み: ${_currentProfile!.skinProblems.join(', ')}
      避けたい成分: ${_currentProfile!.avoidIngredients.join(', ')}
      希望する効果: ${_currentProfile!.desiredEffects.join(', ')}
      特記事項: ${_currentProfile!.note ?? 'なし'}
      ''';

      print('アップロード予定のプロフィールテキスト:\n$profileText');

      // テキストファイルをアップロード
      await profileRef.putString(profileText);
      print('プロフィールテキストのアップロード完了');
    } catch (e) {
      print('プロフィールのアップロードでエラー発生: $e');
      rethrow;
    }
  }

  // 画像をアップロードして解析する
  Future<void> uploadAndAnalyze() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    _resultText = '写真をアップロード中...';
    notifyListeners();

    try {
      String randomNum = (100000 + (DateTime.now().microsecondsSinceEpoch % 900000)).toString();
      String timestamp = DateTime.now().toIso8601String()
                          .replaceAll(RegExp(r'[-:\.TZ]'), '')
                          .substring(0, 14);
      String folderName = '${randomNum}_$timestamp';
      
      String imageUrl = await _uploadImageToFirebase(_selectedImage!, folderName);
      print('画像のアップロード完了: $imageUrl');
      
      if (_currentProfile != null) {
        print('プロフィール情報のアップロードを開始');
        await _uploadProfileToFirebase(folderName);
        _resultText = 'アップロード成功！\n画像とプロフィール情報を保存しました。\nURL: $imageUrl';
      } else {
        print('プロフィール情報が設定されていません');
        _resultText = 'アップロード成功！\n画像のみ保存しました。\nURL: $imageUrl';
      }
      
      _uploadedImageUrl = imageUrl;

      // 30秒後に解析結果を取得
      await Future.delayed(const Duration(seconds: 30));
      await _fetchAnalysisResult(folderName);

    } catch (e) {
      print('エラーが発生: $e');
      _resultText = 'アップロードに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 解析結果を取得するメソッド
  Future<void> _fetchAnalysisResult(String folderName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final analysisRef = storageRef.child('cosmes').child(folderName).child('analysis_result.json');
      
      // ファイルをダウンロード
      final bytes = await analysisRef.getData();
      final String analysisResultStr = utf8.decode(bytes!);
      _analysisResult = json.decode(analysisResultStr);
      print('解析結果: $analysisResultStr');
      notifyListeners(); // 解析結果が更新されたことを通知
    } catch (e) {
      print('解析結果の取得に失敗: $e');
    }
  }
} 