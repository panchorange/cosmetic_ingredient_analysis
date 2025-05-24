import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../viewmodels/picture_viewmodel.dart';
import '../viewmodels/skin_profile_viewmodel.dart';
import 'analysis_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class UserHomePage extends StatelessWidget {
    const UserHomePage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: AppColors.lightPink, // ライトピンク
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
            body: Consumer2<PictureViewModel, SkinProfileViewModel>(
                builder: (context, pictureViewModel, skinProfileViewModel, child) {
                    // プロフィール情報が存在する場合、PictureViewModelに設定
                    if (skinProfileViewModel.profile != null && pictureViewModel.currentProfile == null) {
                        pictureViewModel.setProfile(skinProfileViewModel.profile!);
                        print('プロフィール情報をPictureViewModelに設定しました');
                    }

                    return SingleChildScrollView(
                        child: Center(
                            child: Column(
                                children: [
                                    const SizedBox(height: 20),
                                    Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(horizontal: 20.0),
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                            color: AppColors.lavenderBrush, // ラベンダーブラッシュ
                                            borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                Text(
                                                    '✨ はじめましょう ✨',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.darkSlateGray,
                                                    ),
                                                ),
                                                SizedBox(height: 12),
                                                Text(
                                                    '1. あなたの肌の特徴を教えてね👩',
                                                    style: TextStyle(
                                                        color: AppColors.darkSlateGray,
                                                        fontSize: 16,
                                                    ),
                                                ),
                                                Text(
                                                    '2. お気に入りのコスメを撮影⭐️',
                                                    style: TextStyle(
                                                        color: AppColors.darkSlateGray,
                                                        fontSize: 16,
                                                    ),
                                                ),
                                                Text(
                                                    '3. あなたにへ分析結果をお届け📈',
                                                    style: TextStyle(
                                                        color: AppColors.darkSlateGray,
                                                        fontSize: 16,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    const SizedBox(height: 20),

                                    if (pictureViewModel.selectedImage != null)
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
                                                    pictureViewModel.selectedImage!,
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

                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            ElevatedButton.icon(
                                                onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => Scaffold(
                                                                appBar: AppBar(
                                                                    title: const Text('バーコードスキャン'),
                                                                    backgroundColor: AppColors.lightPink,
                                                                ),
                                                                body: MobileScanner(
                                                                    onDetect: (capture) {
                                                                        final List<Barcode> barcodes = capture.barcodes;
                                                                        for (final barcode in barcodes) {
                                                                            final String barcodeValue = barcode.rawValue ?? '';
                                                                            Navigator.pop(context);
                                                                            
                                                                            // バーコード結果をポップアップで表示
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                    return AlertDialog(
                                                                                        title: const Text('バーコードスキャン完了'),
                                                                                        content: Column(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                                Text('バーコード: $barcodeValue'),
                                                                                                const SizedBox(height: 16),
                                                                                                const Text('次に成分表を撮影してください'),
                                                                                            ],
                                                                                        ),
                                                                                        actions: [
                                                                                            TextButton(
                                                                                                onPressed: () async {
                                                                                                    Navigator.pop(context);
                                                                                                    await pictureViewModel.saveBarcodeToFirebase(barcodeValue);
                                                                                                    // バーコードスキャン後に直接カメラを起動
                                                                                                    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
                                                                                                    if (photo != null) {
                                                                                                        pictureViewModel.processSelectedImage(photo);
                                                                                                    }
                                                                                                },
                                                                                                child: const Text('成分表を撮影'),
                                                                                            ),
                                                                                        ],
                                                                                    );
                                                                                },
                                                                            );
                                                                            break;
                                                                        }
                                                                    },
                                                                ),
                                                            ),
                                                        ),
                                                    );
                                                },
                                                icon: const Icon(Icons.camera_alt_outlined),
                                                label: const Text('撮影する'),
                                                style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                    backgroundColor: AppColors.lightPink,
                                                    foregroundColor: Colors.white,
                                                ),
                                            ),
                                            const SizedBox(width: 16),
                                            ElevatedButton.icon(
                                                onPressed: pictureViewModel.pickFromGallery,
                                                icon: const Icon(Icons.photo_library_outlined),
                                                label: const Text('ギャラリーから選択'),
                                                style: ElevatedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                    backgroundColor: AppColors.lightPink,
                                                    foregroundColor: Colors.white,
                                                ),
                                            ),
                                        ],
                                    ),

                                    const SizedBox(height: 20),

                                    if (pictureViewModel.selectedImage != null)
                                        ElevatedButton.icon(
                                            onPressed: pictureViewModel.isLoading ? null : pictureViewModel.uploadAndAnalyze,
                                            icon: const Icon(Icons.cloud_upload),
                                            label: const Text('アップロードして解析'),
                                            style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                backgroundColor: const Color(0xFFFF69B4), // ホットピンク
                                                foregroundColor: Colors.white,
                                            ),
                                        ),

                                    const SizedBox(height: 20),

                                    if (pictureViewModel.isLoading)
                                        const Column(
                                            children: [
                                                CircularProgressIndicator(),
                                                SizedBox(height: 10),
                                                Text('処理中...'),
                                            ],
                                        ),

                                    if (pictureViewModel.resultText.isNotEmpty)
                                        Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(horizontal: 20.0),
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFFFFF0F5), // ラベンダーブラッシュ
                                                borderRadius: BorderRadius.circular(10.0),
                                            ),
                                            child: Text(pictureViewModel.resultText),
                                        ),
                                ],
                            ),
                        ),
                    );
                },
            ),
            bottomNavigationBar: BottomNavigationBar(
                items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'ホーム',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: 'プロフィール',
                    ),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.bar_chart_outlined),
                        label: '分析',
                    )
                ],
                currentIndex: 0,
                onTap: (index) {
                    if (index == 1) {
                        Navigator.pushNamed(context, '/settings');
                    } else if (index == 2) {
                        Navigator.pushNamed(context, '/analysis');
                    }
                },
            ),
        );
    }
}