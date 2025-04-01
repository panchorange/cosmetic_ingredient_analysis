import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class PictureViewModel extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String _resultText = '';
  File? _selectedImage;
  String? _uploadedImageUrl;

  // Getters
  bool get isLoading => _isLoading;
  String get resultText => _resultText;
  File? get selectedImage => _selectedImage;
  String? get uploadedImageUrl => _uploadedImageUrl;

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
  Future<String> _uploadImageToFirebase(File imageFile) async {
    String fileName = 'cosme_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = FirebaseStorage.instance.ref();
    final cosmesRef = storageRef.child('cosmes/$fileName');

    final uploadTask = cosmesRef.putFile(imageFile);

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
      print('アップロード進行状況: $progress%');
    });

    await uploadTask.whenComplete(() => print('アップロード完了'));
    final downloadUrl = await cosmesRef.getDownloadURL();
    return downloadUrl;
  }

  // 画像をアップロードして解析する
  Future<void> uploadAndAnalyze() async {
    if (_selectedImage == null) return;

    _isLoading = true;
    _resultText = '写真をアップロード中...';
    notifyListeners();

    try {
      String imageUrl = await _uploadImageToFirebase(_selectedImage!);
      _uploadedImageUrl = imageUrl;
      _resultText = 'アップロード成功！\nURL: $imageUrl';
    } catch (e) {
      _resultText = 'アップロードに失敗しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 