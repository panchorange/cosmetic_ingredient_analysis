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
    String? _currentFolderName; // 現在のフォルダ名を保持
    StreamSubscription? _analysisSubscription;
    String? _originalText; // OCRテキストを保持するフィールドを追加

    PictureViewModel(this._skinProfileViewModel) {
        _loadProfile();
    }

    @override
    void dispose() {
        _analysisSubscription?.cancel();
        super.dispose();
    }

    // プロフィール情報を読み込む
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
    String? get originalText => _originalText; // getterを追加

    // プロフィール情報を設定
    void setProfile(SkinProfile profile) {
        _currentProfile = profile;
        print('プロフィール設定: ${profile.toJson()}');
        notifyListeners();
    }

    // バーコードスキャン結果を設定
    void setBarcodeResult(String result) {
        _barcodeResult = result;
        print('バーコードスキャン結果: $result'); // デバッグ表示を追加
        notifyListeners();
    }

    // バーコードスキャン用のプライベートメソッド
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

            // タイムアウトを設定（5秒）
            return await completer.future.timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                    controller.stop();
                    return null;
                }
            );
        } catch (e) {
            print('バーコードスキャンエラー: $e');
            return null;
        }
    }

    // 最新のフォルダ番号を取得するメソッド
    Future<int> _getLatestFolderNumber() async {
        try {
            final storageRef = FirebaseStorage.instance.ref(); // ストレージの参照を取得
            final scanlogRef = storageRef.child('scanlog'); // scanlog/$uidフォルダの参照を取得
            
            // scanlogフォルダ内の全てのフォルダをリストアップ
            final result = await scanlogRef.listAll();
            
            // フォルダ名から数字を抽出して最大値を取得
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
            print('フォルダ番号取得エラー: $e');
            return 0;
        }
    }

    // // 新しいフォルダを作成するメソッド
    Future<String> _createNewFolder() async {
        int latestNumber = await _getLatestFolderNumber();
        _currentFolderName = (latestNumber + 1).toString();
        return _currentFolderName!;
    }

    // バーコードデータをFirebaseに保存
    Future<void> saveBarcodeToFirebase(String barcode) async {
        try {
            // Firebase Authから現在のユーザーのUIDを取得
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
                print('ユーザーがログインしていません');
                return;
            }
            print('現在のユーザーUID: $uid');

            // UIDフォルダの存在確認
            final uidRef = FirebaseStorage.instance.ref().child('scanlog').child(uid);
            final listResult = await uidRef.listAll();
            print('listResult.prefixes.length: ${listResult.prefixes.length}');
            String folderName = (listResult.prefixes.length + 1).toString(); // バーコードデータを保存するフォルダ名を設定
            if (listResult.items.isEmpty && listResult.prefixes.isEmpty) {
                print('UIDフォルダの存在確認: $uid - 存在しません');
            } else {
                print('UIDフォルダの存在確認: $uid - 存在します');
            }
            final barcodeRef = uidRef.child(folderName).child('barcode_$barcode.txt');
            await barcodeRef.putString(barcode);
            _currentFolderName = folderName;
            print('バーコードデータの保存完了: barcode_$barcode.txt $folderName');

            setBarcodeResult(barcode);
        } catch (e) {
            print('バーコードデータの保存でエラー発生: $e');
            rethrow;
        }
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
    Future<String> _saveImageToFirebase(File imageFile, String uid, String folderName) async {
        print('画像アップロード開始: フォルダ名=$folderName');
        final storageRef = FirebaseStorage.instance.ref();
        final cosmesRef = storageRef.child('scanlog').child(uid).child(folderName).child('ocr_source.jpg');
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
            print('アップロード進行状況: ${progress.round()}%');
        });

        await uploadTask.whenComplete(() => print('画像アップロード完了: ${cosmesRef.fullPath}'));
        final downloadUrl = await cosmesRef.getDownloadURL();
        return downloadUrl;
    }

    // 年齢を計算するメソッド
    int _calculateAge(DateTime birthDate) {
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || 
            (now.month == birthDate.month && now.day < birthDate.day)) {
            age--;
        }
        return age;
    }

    // プロフィール情報をテキストファイルとしてアップロード
    Future<void> _uploadProfileToFirebase(String uid, String folderName) async {
        print('_uploadProfileToFirebase called with folderName: $folderName');
        if (_currentProfile == null) {
            print('プロフィール情報が null です');
            return;
        }

        try {
            final storageRef = FirebaseStorage.instance.ref();
            // フォルダ構造を作成するためにフォルダ名とファイル名を分けて指定
            final profileRef = storageRef.child('scanlog').child(uid).child(folderName).child('profile.txt');

            // 年齢を計算
            int age = _calculateAge(_currentProfile!.birthDate);

            // プロフィール情報をテキスト形式に変換
            String profileText = '''
            年齢: $age歳
            性別: ${_currentProfile!.gender}
            肌タイプ: ${_currentProfile!.skinType}
            肌悩み: ${_currentProfile!.skinProblems.join(', ')}
            避けたい成分: ${_currentProfile!.avoidIngredients.join(', ')}
            希望する効果: ${_currentProfile!.desiredEffects.join(', ')}
            特記事項: ${_currentProfile!.note ?? 'なし'}
            ''';

            print('アップロード予定のプロフィール:\n$profileText');

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
            // プロフィール情報を再読み込み
            await _loadProfile();

            // プロフィール情報が存在する場合は保存
            final uid = FirebaseAuth.instance.currentUser?.uid;
            if (uid == null) {
                print('ユーザーがログインしていません');
                return;
            }
            await _uploadProfileToFirebase(uid, _currentFolderName!);
            print('プロフィール情報を保存しました: folder $_currentFolderName');
            
            // バーコードスキャンが完了していない場合は新しいフォルダを作成
            String imageUrl = await _saveImageToFirebase(_selectedImage!, uid, _currentFolderName!);
            print('画像のアップロード完了: $imageUrl');

            _uploadedImageUrl = imageUrl;

            // アップロード完了後、少し待機してファイルが利用可能になるのを待つ
            await Future.delayed(const Duration(seconds: 2));

            // 分析リクエストを送信
            print('currentFolderName: $_currentFolderName');
            print('folderPath: scanlog/$uid/$_currentFolderName');

            // プロフィール情報をJSONに変換(BigQueryに送信するため)
            Map<String, dynamic> userProfileJson = {
                'uid': uid,
                'birth_date': _currentProfile!.birthDate.toIso8601String(), // ISO 8601形式の日付文字列
                'gender': _currentProfile!.gender,
                'skin_type': _currentProfile!.skinType,
                'skin_problems': _currentProfile!.skinProblems.toList(), // 配列として送信
                'avoid_ingredients': _currentProfile!.avoidIngredients.toList(), // 配列として送信
                'desired_effects': _currentProfile!.desiredEffects.toList(), // 配列として送信
                'note': _currentProfile!.note,
                'created_at': DateTime.now().toIso8601String(), // レコード作成時刻
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

            print('Server response: ${response.body}'); // デバッグ用にレスポンスを表示

            if (response.statusCode == 200) {
                final responseData = json.decode(response.body);
                print('responseData.runtimeType: ${responseData.runtimeType}');
                // analysisの文字列をJSONとしてパース
                _analysisResult = json.decode(responseData['data']['analysis_result']);
                print('_analysisResult.runtimeType: ${_analysisResult.runtimeType}');
                print('analysis result: $_analysisResult'); // デバッグ用に解析結果を表示
            } else {
                throw Exception('サーバーエラー: ${response.statusCode}');
            }
            _resultText = '分析が完了しました！';

        } catch (e) {
            print('エラーが発生: $e');
            _resultText = 'アップロードあるいは分析に失敗しました: $e';
        } finally {
            _isLoading = false;
            notifyListeners();
        }
    }
}