import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
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

  // 画像を撮影するメソッド
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      // 撮影成功した場合の処理
      print('写真が撮影されました: ${photo.path}');
      setState(() {
        _isLoading = true;
        _resultText = '写真を解析中...';
      });
      try {
        // 画像をFirebase Storageにアップロード
        // String imageUrl = await _uploadImageToFirebase(photo);
        print("画像をアップロードする処理");
      } catch (e) {
        setState((){
          _resultText = '解析に失敗しました: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }

    }
  }
    // Firebase Storageにアップロードするメソッド
  // Future<String> _uploadImageToFirebase(XFile imageFile) async {
  //   // ユニークなファイル名を生成
  //   String fileName = 'cosme_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
  //   // Storageの参照を作成
  //   final storageRef = FirebaseStorage.instance.ref();
  //   final cosmesRef = storageRef.child('cosmes/$fileName');
    
  //   // ファイルをアップロード
  //   File file = File(imageFile.path);
  //   await cosmesRef.putFile(file);
    
  //   // アップロードしたファイルのURLを取得
  //   final downloadUrl = await cosmesRef.getDownloadURL();
  //   return downloadUrl;
  // }


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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使い方のテキスト
            const SizedBox(height: 30),
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
            const SizedBox(height: 30),

            // 撮影するボタン
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('撮影する'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}