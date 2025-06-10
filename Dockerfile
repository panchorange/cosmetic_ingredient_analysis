# Stage 1: Flutterビルド環境
FROM ghcr.io/cirruslabs/flutter:stable AS build

# 作業ディレクトリを設定
WORKDIR /app

# 環境変数を設定（Web環境での不要な警告を抑制）
ENV FLUTTER_WEB=true

# pubspec.yamlとpubspec.lockをコピーして依存関係をインストール
COPY pubspec.* ./
RUN flutter pub get

# ソースコードをコピー
COPY . .

# Flutter doctor を実行してWeb環境の確認
RUN flutter doctor -v

# Flutter Webアプリをビルド（より詳細なログ出力）
RUN flutter build web --release --verbose

# Stage 2: Nginx本番環境
FROM nginx:alpine

# ビルド結果をNginxの公開ディレクトリにコピー
COPY --from=build /app/build/web /usr/share/nginx/html

# カスタムnginx設定をコピー
COPY nginx.conf /etc/nginx/nginx.conf

# Cloud Runはポート8080を期待
EXPOSE 8080

# Nginxを起動
CMD ["nginx", "-g", "daemon off;"]