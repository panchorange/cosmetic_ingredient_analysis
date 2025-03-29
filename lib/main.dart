import 'package:flutter/material.dart';

void main() {
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
                  fontSize:24,
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
                children: [  // ここの const を削除
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
            ElevatedButton(
              onPressed: () {
                print('撮影するボタンが押されました');
              },
              child: const Text('撮影する'),
            ),
          ],
        ),
      ),
    );
  }
}