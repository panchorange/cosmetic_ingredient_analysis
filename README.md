# 化粧品成分分析AIエージェント


## 開発者用メモ

### webアプリのリリース
docer containerをcloud runで動かす。
手順
1. local:Dockerfileのbuild+push
    *  linux/amd64 でbuildする。
```
docker buildx build --platform linux/amd64 -t myapp --push .
```
2. local: tag付け
```
docker tag cosme-analyze:0.1 asia-northeast1-docker.pkg.dev/cosmetic-ingredient-analysis/cosme-analyze-web/cosme-analyze:0.1
```
3. gcp:artifact registoryへpush

```
docker push asia-northeast1-docker.pkg.dev/cosmetic-ingredient-analysis/cosme-analyze-web/cosme-analyze:0.1
```

