# 💄 コスメ成分分析アプリ

化粧品選びで迷ったことはありませんか？ 😊  
このアプリは、あなたの肌にぴったりの化粧品を見つけるお手伝いをします！ ✨

## 🌸 アプリについて

あなた専用の美容アドバイザーがスマホの中に！ 📱💕

- **🔐 ユーザー認証**: あなただけの安全な美容記録を作成
- **👤 肌プロファイル管理**: 乾燥肌？脂性肌？あなたの肌タイプをしっかり記録
- **📸 成分分析**: 気になる化粧品をパシャッと撮影するだけで成分をチェック！
- **⭐ パーソナライズされた評価**: あなたの肌に合うかどうかを○×で判定
- **🎨 美しいUI**: 可愛いピンクのデザインで使うのが楽しくなる♪

## コード構成（lib/）

### メインファイル
- **main.dart**: アプリケーションのエントリーポイント。Firebase初期化、Provider設定、テーマ設定を行う

### Views（画面）
- **login_page.dart**: ユーザーログイン画面。認証機能のUI部分を提供
- **user_home.dart**: メインのホーム画面。アプリの主要機能へのナビゲーション
- **skin_profile_page.dart**: 肌プロファイル設定画面。個人の肌タイプ情報を管理
- **analysis_page.dart**: 成分分析画面。化粧品成分の分析結果を表示

### ViewModels（ビジネスロジック）
- **auth_viewmodel.dart**: 認証関連のビジネスロジック。ログイン/ログアウト状態管理
- **picture_viewmodel.dart**: 画像処理・分析のビジネスロジック。写真から成分情報を抽出
- **skin_profile_viewmodel.dart**: 肌プロファイル管理のビジネスロジック。個人設定の保存・取得

### Models（データモデル）
- **skin_profile.dart**: 肌プロファイルのデータ構造。肌タイプや悩みなどの情報を定義

### Utils（ユーティリティ）
- **utils/contents/**: 成分データベースや分析に使用する各種データファイル

## Webアプリの使い方
### デプロイ済みサイト
- 本番環境: https://cosme-analyze-1037062375017.asia-northeast1.run.app

### ローカル実行
```bash
flutter run -d chrome
```

## Androidアプリの使い方
Android StudioへUSBケーブルを使ってスマホ接続をした上での動作を想定しております。
* [PC]Android Studioのインストール
   * https://developer.android.com/studio/install?hl=ja
* [Androidスマホ]開発者ツールの設定
   * https://developer.android.com/studio/debug/dev-options?hl=ja
を行った上で、以下を実施してください。

### Windowsでのビルド

1. **環境設定**
```bash
# Flutter SDKのインストール確認
flutter doctor

# 依存関係のインストール
flutter pub get
```

2. **APKビルド**
```bash
# リリースビルド
flutter build apk --release

# デバッグビルド
flutter build apk --debug
```

### macOSでのビルド

1. **環境設定**
```bash
# Flutter SDKのインストール確認
flutter doctor

# 依存関係のインストール
flutter pub get

# iOS開発用ツールの確認（iOS対応の場合）
xcode-select --install
```

2. **APKビルド**
```bash
# リリースビルド
flutter build apk --release

# Bundleビルド（Google Play Store用）
flutter build appbundle --release
```

### Androidでのflutter run

1. **デバイスの準備**
   - 開発者オプションを有効化
   - USBデバッグを有効化
   - デバイスをUSBで接続

2. **実行**
```bash
# デバイス確認
flutter devices

# アプリの実行
flutter run

# ホットリロード対応で実行
flutter run --hot
```

### iOSでのflutter run

1. **前提条件**
   - macOS環境
   - Xcode インストール済み
   - iOS Developer アカウント（実機の場合）

2. **シミュレーター実行**
```bash
# iOSシミュレーターの起動
open -a Simulator

# アプリの実行
flutter run -d ios
```

3. **実機実行**
```bash
# デバイス確認
flutter devices

# 実機での実行
flutter run -d [device-id]
```

## 開発環境のセットアップ

```bash
# リポジトリのクローン
git clone [repository-url]
cd cosmetic_ingredient_analysis

# 依存関係のインストール
flutter pub get

# Firebaseの設定（Firebase CLIが必要）
firebase login
firebase use [project-id]

# アプリの実行
flutter run
```

## 貢献について

プルリクエストやイシューの報告を歓迎します。開発に参加される場合は、まず既存のイシューを確認してください。
