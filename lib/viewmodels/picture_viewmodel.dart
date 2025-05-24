import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/skin_profile.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'skin_profile_viewmodel.dart';
import 'package:http/http.dart' as http;

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
    String? _uploadedImageUrl;
    SkinProfile? _currentProfile;
    Map<String, dynamic>? _analysisResult;
    String? _barcodeResult;
    String? _currentFolderName;
    StreamSubscription? _analysisSubscription;
    String? _originalText;

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
    String? get uploadedImageUrl => _uploadedImageUrl;
    SkinProfile? get currentProfile => _currentProfile;
    Map<String, dynamic>? get analysisResult => _analysisResult;
    String? get barcodeResult => _barcodeResult;
    String? get originalText => _originalText;

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

    /// バーコードをスキャンする
    /// 
    /// 5秒のタイムアウトが設定されています。
    /// 
    /// 戻り値:
    /// - スキャンに成功した場合: バーコードの値
    /// - スキャンに失敗またはタイムアウトした場合: null
    Future<String?> _scanBarcode() async {
        try {
            final MobileScannerController controller = MobileScannerController();
            final Completer<String?> completer = Completer<String?>();
            
            controller.start();
            
            controller.barcodes.listen((capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                    final barcode = barcodes.first.rawValue;
                    controller.stop();
                    completer.complete(barcode);
                }
            });

            return await completer.future.timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                    controller.stop();
                    return null;
                }
            );
        } catch (e) {
            return null;
        }
    }

    /// 最新のフォルダ番号を取得
    /// 
    /// Firebaseストレージ内の最新のフォルダ番号を取得します。
    /// 
    /// 戻り値:
    /// - 成功時: 最新のフォルダ番号
    /// - 失敗時: 0
    Future<int> _getLatestFolderNumber() async {
        try {
            final storageRef = FirebaseStorage.instance.ref();
            final scanlogRef = storageRef.child('scanlog');
            final result = await scanlogRef.listAll();
            
            int maxNumber = 0;
            for (var folder in result.prefixes) {
                final folderName = folder.name;
                final number = int.tryParse(folderName);
                if (number != null && number > maxNumber) {
                    maxNumber = number;
                }
            }
            
            return maxNumber;
        } catch (e) {
            return 0;
        }
    }

    /// 新しいフォルダを作成
    /// 
    /// 戻り値: 作成されたフォルダ名
    Future<String> _createNewFolder() async {
        int latestNumber = await _getLatestFolderNumber();
        _currentFolderName = (latestNumber + 1).toString();
        return _currentFolderName!;
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

            final uidRef = FirebaseStorage.instance.ref().child('scanlog').child(uid);
            final listResult = await uidRef.listAll();
            String folderName = (listResult.prefixes.length + 1).toString();
            
            final barcodeRef = uidRef.child(folderName).child('barcode_$barcode.txt');
            await barcodeRef.putString(barcode);
            _currentFolderName = folderName;

            setBarcodeResult(barcode);
        } catch (e) {
            rethrow;
        }
    }

    /// ギャラリーから画像を選択
    Future<void> pickFromGallery() async {
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        processSelectedImage(image);
    }

    /// 選択された画像を処理
    /// 
    /// [imageFile] 処理する画像ファイル
    void processSelectedImage(XFile? imageFile) {
        if (imageFile != null) {
            _selectedImage = File(imageFile.path);
            _isLoading = false;
            _resultText = '';
            _uploadedImageUrl = null;
            notifyListeners();
        }
    }

    /// 画像をFirebase Storageにアップロード
    /// 
    /// [imageFile] アップロードする画像ファイル
    /// [uid] ユーザーID
    /// [folderName] 保存先フォルダ名
    /// 
    /// 戻り値: アップロードされた画像のダウンロードURL
    Future<String> _saveImageToFirebase(File imageFile, String uid, String folderName) async {
        final storageRef = FirebaseStorage.instance.ref();
        final cosmesRef = storageRef.child('scanlog').child(uid).child(folderName).child('ocr_source.jpg');

        final uploadTask = cosmesRef.putFile(
            imageFile,
            SettableMetadata(
                contentType: 'image/jpeg',
                customMetadata: {'uploaded_by': 'app'}
            )
        );

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
            return;
        }

        try {
            final storageRef = FirebaseStorage.instance.ref();
            final profileRef = storageRef.child('scanlog').child(uid).child(folderName).child('profile.txt');

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

            await profileRef.putString(profileText);
        } catch (e) {
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
        if (_selectedImage == null) return;

        _isLoading = true;
        _resultText = '写真をアップロード中...';
        notifyListeners();

        try {
            await _loadProfile();

            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
                return;
            }
            await _uploadProfileToFirebase(uid, _currentFolderName!);
            
            String imageUrl = await _saveImageToFirebase(_selectedImage!, uid, _currentFolderName!);
            _uploadedImageUrl = imageUrl;

            await Future.delayed(const Duration(seconds: 2));

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

            final response = await http.post(
                Uri.parse('https://asia-northeast1-cosmetic-ingredient-analysis.cloudfunctions.net/analyzeIngredients'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                    'firebaseFolderPath': 'scanlog/$uid/$_currentFolderName',
                    'barcode': _barcodeResult,
                    'userProfileJson': userProfileJson
                })
            );

            if (response.statusCode == 200) {
                final responseData = json.decode(response.body);
                _analysisResult = json.decode(responseData['data']['analysis_result']);
            } else {
                throw Exception('サーバーエラー: ${response.statusCode}');
            }
            _resultText = '分析が完了しました！';

        } catch (e) {
            _resultText = 'アップロードあるいは分析に失敗しました: $e';
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }
}