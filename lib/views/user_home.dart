import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../viewmodels/picture_viewmodel.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

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
      body: Consumer<PictureViewModel>(
        builder: (context, viewModel, child) {
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
                      color: Colors.blue.shade200,
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

                  if (viewModel.selectedImage != null)
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
                          viewModel.selectedImage!,
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
                        onPressed: viewModel.takePhoto,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('撮影する'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: viewModel.pickFromGallery,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('ギャラリーから選択'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (viewModel.selectedImage != null)
                    ElevatedButton.icon(
                      onPressed: viewModel.isLoading ? null : viewModel.uploadAndAnalyze,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('アップロードして解析'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),

                  const SizedBox(height: 20),

                  if (viewModel.isLoading)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('処理中...'),
                      ],
                    ),

                  if (viewModel.resultText.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(viewModel.resultText),
                    ),

                  const SizedBox(height: 20),

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
            icon: Icon(Icons.settings),
            label: '設定',
          )
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }
} 