import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // ゲッター
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get errorMessage => _errorMessage;
  
  // コンストラクタ
  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }
  
  // Googleでサインイン
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Googleサインインフローの開始
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // ユーザーがサインインをキャンセルした場合
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // 認証情報の取得
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Firebase Authでサインイン
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      _currentUser = userCredential.user;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('Google サインインエラー: $e');
      return false;
    }
  }
  
  // サインアウト
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('サインアウトエラー: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 