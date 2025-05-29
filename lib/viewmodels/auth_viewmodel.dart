import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// 認証状態を管理するViewModel
///
/// このクラスは以下の機能を提供します：
/// - Googleアカウントを使用したサインイン
/// - サインアウト
/// - 認証状態の監視
/// - ユーザー情報の取得
class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  /// 現在サインインしているユーザー
  User? get currentUser => _currentUser;

  /// 認証処理中かどうかを示すフラグ
  bool get isLoading => _isLoading;

  /// ユーザーがサインインしているかどうかを示すフラグ
  bool get isLoggedIn => _currentUser != null;

  /// 認証処理中に発生したエラーメッセージ
  String? get errorMessage => _errorMessage;

  /// コンストラクタ
  ///
  /// Firebase Authの認証状態の変更を監視し、
  /// 変更があった場合にリスナーに通知します。
  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// 現在サインインしているユーザーのUIDを取得
  ///
  /// 戻り値:
  /// - サインイン中: ユーザーのUID
  /// - 未サインイン: null
  String? getCurrentUid() {
    return _currentUser?.uid;
  }

  /// Googleアカウントを使用してサインイン
  ///
  /// このメソッドは以下の手順を実行します：
  /// 1. Googleサインインダイアログを表示
  /// 2. ユーザーが選択したアカウントの認証情報を取得
  /// 3. 取得した認証情報でFirebase Authにサインイン
  ///
  /// 戻り値:
  /// - サインイン成功: true
  /// - サインイン失敗またはキャンセル: false
  ///
  /// エラーが発生した場合は[errorMessage]にエラー内容が設定されます。
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      _currentUser = userCredential.user;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// サインアウト
  ///
  /// このメソッドは以下の処理を実行します：
  /// 1. Googleサインアウト
  /// 2. Firebase Authからのサインアウト
  ///
  /// エラーが発生した場合は[errorMessage]にエラー内容が設定されます。
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
