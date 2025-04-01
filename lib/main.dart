import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase手動初期化
  await Firebase.initializeApp(); // android/app/google-services.jsonの中身を使ってfirebase prjと接続
  
  runApp(const CosmeAnalyzer());
}

class CosmeAnalyzer extends StatelessWidget {
  const CosmeAnalyzer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'コスメ成分分析',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const UserHomePage(),
    );
  }
}

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _resultText = '';
  File? _selectedImage;
  String? _uploadedImageUrl;

  // 画像を撮影するメソッド
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    _processSelectedImage(photo);
  }
  
  // ギャラリーから画像を選択するメソッド
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    _processSelectedImage(image);
  }
  
  // 画像の処理を行うメソッド
  void _processSelectedImage(XFile? imageFile) {
    if (imageFile != null) {
      setState(() {
        _selectedImage = File(imageFile.path);
        _isLoading = false;
        _resultText = '';
        _uploadedImageUrl = null;
      });
    }
  }

  // Firebase Storageにアップロードするメソッド
  Future<String> _uploadImageToFirebase(File imageFile) async {
    // ユニークなファイル名を生成
    String fileName = 'cosme_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
    // Storageの参照を作成
    final storageRef = FirebaseStorage.instance.ref();
    final cosmesRef = storageRef.child('cosmes/$fileName');
    
    // ファイルをアップロード
    final uploadTask = cosmesRef.putFile(imageFile);
    
    // アップロードの進行状況を監視（オプション）
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      print('アップロード進行状況: $progress%');
    });
    
    // アップロード完了を待機
    await uploadTask.whenComplete(() => print('アップロード完了'));
    
    // アップロードしたファイルのURLを取得
    final downloadUrl = await cosmesRef.getDownloadURL();
    return downloadUrl;
  }
  
  // 画像をアップロードして解析する
  Future<void> _uploadAndAnalyze() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isLoading = true;
      _resultText = '写真をアップロード中...';
    });
    
    try {
      // 画像をFirebase Storageにアップロード
      String imageUrl = await _uploadImageToFirebase(_selectedImage!);
      
      setState(() {
        _uploadedImageUrl = imageUrl;
        _resultText = 'アップロード成功！\nURL: $imageUrl';
      });
      
      // ここで画像解析サービスを呼び出すなどの追加処理
      
    } catch (e) {
      setState(() {
        _resultText = 'アップロードに失敗しました: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
              'コスメ成分分析',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  letterSpacing: 2.0
              )
          ),
          centerTitle: true
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // 使い方のテキスト
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使い方',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('1. コスメ製品を撮影またはアップロード'),
                    Text('2. AIが成分を解析します'),
                    Text('3. あなたのプロフィールに基づいてアドバイス'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 選択した画像を表示
              if (_selectedImage != null)
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('画像が選択されていません'),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 画像選択ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('撮影する'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリーから選択'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // アップロードボタン
              if (_selectedImage != null)
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadAndAnalyze,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('アップロードして解析'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // 読み込み中インジケーター
              if (_isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('処理中...'),
                  ],
                ),
              
              // 結果表示
              if (_resultText.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(_resultText),
                ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}