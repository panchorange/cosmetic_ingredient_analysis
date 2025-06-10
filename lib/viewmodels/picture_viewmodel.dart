import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/skin_profile.dart';
import 'dart:convert';
import 'dart:async';
import 'skin_profile_viewmodel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

/// 画像の取り扱いとその分析を管理するViewModel
///
/// 主な機能:
/// - 画像の選択と保存
/// - バーコードのスキャンと保存
/// - プロフィール情報の管理
/// - 成分分析の実行
class PictureViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final SkinProfileViewModel _skinProfileViewModel;
  bool _isLoading = false;
  String _resultText = '';
  File? _selectedImage;
  Uint8List? _selectedImageBytes; // Web用の画像データ
  String? _uploadedImageUrl;
  SkinProfile? _currentProfile;
  Map<String, dynamic>? _analysisResult;
  String? _barcodeResult;
  String? _currentFolderName;
  StreamSubscription? _analysisSubscription;
  String? _originalText;
  bool _isBarcodeScanMode = true; // true: バーコード撮影モード, false: 成分撮影モード

  /// コンストラクタ
  ///
  /// [_skinProfileViewModel] スキンプロフィール情報を管理するViewModel
  PictureViewModel(this._skinProfileViewModel) {
    _loadProfile();
  }

  @override
  void dispose() {
    _analysisSubscription?.cancel();
    super.dispose();
  }

  /// プロフィール情報を読み込む
  ///
  /// [_skinProfileViewModel]から最新のプロフィール情報を取得し、
  /// 現在のプロフィールとして設定します。
  Future<void> _loadProfile() async {
    await _skinProfileViewModel.loadProfile();
    _currentProfile = _skinProfileViewModel.profile;
    notifyListeners();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get resultText => _resultText;
  File? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes; // Web用getter
  String? get uploadedImageUrl => _uploadedImageUrl;
  SkinProfile? get currentProfile => _currentProfile;
  Map<String, dynamic>? get analysisResult => _analysisResult;
  String? get barcodeResult => _barcodeResult;
  String? get originalText => _originalText;
  bool get isBarcodeScanMode => _isBarcodeScanMode;

  /// プロフィール情報を設定
  ///
  /// [profile] 設定するプロフィール情報
  void setProfile(SkinProfile profile) {
    _currentProfile = profile;
    notifyListeners();
  }

  /// バーコードスキャン結果を設定
  ///
  /// [result] スキャンされたバーコードの値
  void setBarcodeResult(String result) {
    _barcodeResult = result;
    notifyListeners();
  }

  /// 手動でバーコードを設定し、Firebaseに保存
  ///
  /// [barcode] 手動で入力されたバーコード値（空文字またはnullの場合は"99"）
  Future<void> setManualBarcode(String? barcode) async {
    try {
      // 入力がない場合は"99"を使用
      final barcodeValue =
          (barcode == null || barcode.trim().isEmpty) ? "99" : barcode.trim();

      debugPrint('手動バーコード設定: $barcodeValue');
      setBarcodeResult(barcodeValue);
      await saveBarcodeToFirebase(barcodeValue);
    } catch (e) {
      debugPrint('手動バーコード設定エラー: $e');
    }
  }

  /// 撮影モードを成分撮影に切り替え
  void switchToIngredientMode() {
    _isBarcodeScanMode = false;
    notifyListeners();
  }

  /// 撮影モードをリセット（バーコード撮影モードに戻す）
  void resetScanMode() {
    _isBarcodeScanMode = true;
    _barcodeResult = null;
    _selectedImage = null;
    _selectedImageBytes = null;
    _analysisResult = null;
    _resultText = '';
    notifyListeners();
  }

  /// バーコードデータをFirebaseに保存
  ///
  /// [barcode] 保存するバーコードの値
  ///
  /// 例外:
  /// - ユーザーが未ログインの場合
  /// - Firebaseへの保存に失敗した場合
  Future<void> saveBarcodeToFirebase(String barcode) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return;
      }

      // 既存のフォルダ名がない場合のみ新しいフォルダを作成
      _currentFolderName ??= DateTime.now().millisecondsSinceEpoch.toString();

      final uidRef = FirebaseStorage.instance.ref().child('scanlog').child(uid);
      final barcodeRef = uidRef
          .child(_currentFolderName!)
          .child('barcode_$barcode.txt');

      // ファイルの中身を決定：入力があれば入力値、なければ"unknown"
      final fileContent = barcode == "500" ? "unknown" : barcode;

      debugPrint('バーコードファイル保存: barcode_$barcode.txt (中身: $fileContent)');
      await barcodeRef.putString(fileContent);
      debugPrint('バーコードファイル保存完了');
    } catch (e) {
      rethrow;
    }
  }

  /// ギャラリーからファイルを選択
  Future<void> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    // 選択された画像を処理
    processSelectedImage(image);
  }

  /// カメラで撮影
  Future<void> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    // 撮影された画像を処理
    processSelectedImage(image);
  }

  /// 選択された画像を処理
  ///
  /// [imageFile] 処理する画像ファイル
  void processSelectedImage(XFile? imageFile) async {
    if (imageFile != null) {
      if (kIsWeb) {
        // Web環境では画像をUint8Listとして読み込み
        _selectedImageBytes = await imageFile.readAsBytes();
        _selectedImage = null;
      } else {
        // Mobile環境ではFileとして処理
        _selectedImage = File(imageFile.path);
        _selectedImageBytes = null;
      }
      _isLoading = false;
      _resultText = '';
      _uploadedImageUrl = null;
      notifyListeners();
    }
  }

  /// 画像をFirebase Storageにアップロード
  ///
  /// [imageFile] アップロードする画像ファイル（Mobile用）
  /// [imageBytes] アップロードする画像データ（Web用）
  /// [uid] ユーザーID
  /// [folderName] 保存先フォルダ名
  ///
  /// 戻り値: アップロードされた画像のダウンロードURL
  Future<String> _saveImageToFirebase(
    String uid,
    String folderName, {
    File? imageFile,
    Uint8List? imageBytes,
  }) async {
    final storageRef = FirebaseStorage.instance.ref();
    final cosmesRef = storageRef
        .child('scanlog')
        .child(uid)
        .child(folderName)
        .child('ocr_source.jpg');

    late UploadTask uploadTask;

    if (kIsWeb && imageBytes != null) {
      // Web環境ではUint8Listを使用
      uploadTask = cosmesRef.putData(
        imageBytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': 'app'},
        ),
      );
    } else if (!kIsWeb && imageFile != null) {
      // Mobile環境ではFileを使用
      uploadTask = cosmesRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_by': 'app'},
        ),
      );
    } else {
      throw Exception('画像データが不正です');
    }

    await uploadTask.whenComplete(() {});
    final downloadUrl = await cosmesRef.getDownloadURL();
    return downloadUrl;
  }

  /// 年齢を計算
  ///
  /// [birthDate] 生年月日
  ///
  /// 戻り値: 計算された年齢
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// プロフィール情報をFirebaseにアップロード
  ///
  /// [uid] ユーザーID
  /// [folderName] 保存先フォルダ名
  ///
  /// 例外:
  /// - プロフィール情報が存在しない場合
  /// - アップロードに失敗した場合
  Future<void> _uploadProfileToFirebase(String uid, String folderName) async {
    if (_currentProfile == null) {
      debugPrint('プロフィール情報が存在しません');
      return;
    }

    try {
      debugPrint('プロフィールアップロード開始: scanlog/$uid/$folderName/profile.txt');

      final storageRef = FirebaseStorage.instance.ref();
      final profileRef = storageRef
          .child('scanlog')
          .child(uid)
          .child(folderName)
          .child('profile.txt');

      int age = _calculateAge(_currentProfile!.birthDate);

      String profileText = '''
            年齢: $age歳
            性別: ${_currentProfile!.gender}
            肌タイプ: ${_currentProfile!.skinType}
            肌悩み: ${_currentProfile!.skinProblems.join(', ')}
            避けたい成分: ${_currentProfile!.avoidIngredients.join(', ')}
            希望する効果: ${_currentProfile!.desiredEffects.join(', ')}
            特記事項: ${_currentProfile!.note ?? 'なし'}
            ''';

      debugPrint('プロフィール内容: $profileText');

      await profileRef.putString(profileText);
      debugPrint('プロフィールアップロード成功');
    } catch (e) {
      debugPrint('プロフィールアップロードエラー: $e');
      rethrow;
    }
  }

  /// 画像をアップロードして成分分析を実行
  ///
  /// このメソッドは以下の手順を実行します：
  /// 1. プロフィール情報の読み込み
  /// 2. プロフィール情報のアップロード
  /// 3. 画像のアップロード
  /// 4. 成分分析の実行
  ///
  /// 例外:
  /// - 画像が選択されていない場合
  /// - ユーザーが未ログインの場合
  /// - アップロードに失敗した場合
  /// - 分析に失敗した場合
  Future<void> uploadAndAnalyze() async {
    // Web環境とMobile環境で画像データの存在チェック
    if ((kIsWeb && _selectedImageBytes == null) ||
        (!kIsWeb && _selectedImage == null)) {
      return;
    }

    _isLoading = true;
    _resultText = '写真をアップロード中...';
    notifyListeners();

    try {
      await _loadProfile();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        return;
      }

      // 既存のフォルダ名がない場合のみ新しいフォルダを作成
      _currentFolderName ??= DateTime.now().millisecondsSinceEpoch.toString();

      await _uploadProfileToFirebase(uid, _currentFolderName!);

      String imageUrl = await _saveImageToFirebase(
        uid,
        _currentFolderName!,
        imageFile: _selectedImage,
        imageBytes: _selectedImageBytes,
      );
      _uploadedImageUrl = imageUrl;

      // Firebase Storageのファイルが確実に保存されるまで待機
      debugPrint('Firebase Storageファイル保存完了待機中...');
      await Future.delayed(const Duration(seconds: 3));

      Map<String, dynamic> userProfileJson = {
        'uid': uid,
        'birth_date': _currentProfile!.birthDate.toIso8601String(),
        'gender': _currentProfile!.gender,
        'skin_type': _currentProfile!.skinType,
        'skin_problems': _currentProfile!.skinProblems.toList(),
        'avoid_ingredients': _currentProfile!.avoidIngredients.toList(),
        'desired_effects': _currentProfile!.desiredEffects.toList(),
        'note': _currentProfile!.note,
        'created_at': DateTime.now().toIso8601String(),
      };

      final requestBody = {
        'firebaseFolderPath': 'scanlog/$uid/$_currentFolderName',
        'barcode': _barcodeResult ?? '500', // バーコードが設定されていない場合は'500'を送信
        'userProfileJson': userProfileJson,
      };

      debugPrint('=== API リクエスト詳細 ===');
      debugPrint(
        'URL: https://asia-northeast1-cosmetic-ingredient-analysis.cloudfunctions.net/analyzeIngredients',
      );
      debugPrint('リクエストボディ: ${json.encode(requestBody)}');
      debugPrint('送信パラメータ:');
      debugPrint('  - firebaseFolderPath: ${requestBody['firebaseFolderPath']}');
      debugPrint('  - barcode: ${requestBody['barcode']} (${_barcodeResult == null ? 'デフォルト値' : 'スキャン値'})');
      debugPrint('  - userProfileJson keys: ${userProfileJson.keys.toList()}');

      final response = await http.post(
        Uri.parse(
          'https://asia-northeast1-cosmetic-ingredient-analysis.cloudfunctions.net/analyzeIngredients',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      debugPrint('=== API レスポンス詳細 ===');
      debugPrint('ステータスコード: ${response.statusCode}');
      debugPrint('レスポンスヘッダー: ${response.headers}');
      debugPrint('レスポンスボディ: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _analysisResult = json.decode(responseData['data']['analysis_result']);
        debugPrint('_analysisResult: $_analysisResult');
        _resultText = '分析が完了しました！';
      } else {
        debugPrint('エラーレスポンス: ${response.body}');

        // エラーレスポンスの詳細を解析
        String errorMessage = 'サーバーエラーが発生しました';
        try {
          final errorData = json.decode(response.body);
          debugPrint('パースされたエラーデータ: $errorData');
          
          if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
          if (errorData['message'] != null &&
              errorData['message'].toString().isNotEmpty) {
            errorMessage += ': ${errorData['message']}';
          }
          if (errorData['details'] != null) {
            errorMessage += ' (詳細: ${errorData['details']})';
          }
        } catch (parseError) {
          debugPrint('エラーレスポンスの解析に失敗: $parseError');
          errorMessage = 'サーバーエラー (${response.statusCode}): ${response.body}';
        }

        _resultText = errorMessage;
        debugPrint('処理済みエラーメッセージ: $errorMessage');
      }
    } catch (e) {
      debugPrint('例外が発生しました: $e');
      _resultText = 'アップロードあるいは分析に失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
