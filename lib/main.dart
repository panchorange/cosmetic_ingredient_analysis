import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // カメラを起動して画像を撮影する関数
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo == null) return;

      setState(() {
        _image = File(photo.path);
      });

      print('画像が撮影されました: ${photo.path}');
      // await _uploadImage();
    } catch (e) {
      print('カメラエラー: $e');
    }
  }

  // 画像をFirebase Storageにアップロードする関数
  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child('cosmetic_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(_image!);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _isUploading = false;
      });

      print('画像がアップロードされました: $downloadUrl');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像のアップロードに成功しました')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('アップロードエラー: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アップロードエラー: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('コスメ成分分析', style: TextStyle(color: Colors.white)),
          centerTitle: true
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(_image!),
              ),
            const SizedBox(height: 20),
            if (_isUploading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('撮影する'),
            ),
          ],
        ),
      ),
    );
  }
}