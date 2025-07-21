# Dify on AWS App Runner デプロイガイド

## 前提条件

以下のAWSサービスが必要です：

1. **Amazon RDS (PostgreSQL)**
   - PostgreSQL 13以上
   - データベース名: `dify`
   - パブリックアクセス有効

2. **Amazon ElastiCache (Redis)**
   - Redis 6.0以上
   - VPC内配置推奨

## デプロイ手順

### 1. リポジトリの準備
```bash
# GitHubリポジトリを作成し、以下のファイルをpush
- apprunner.yaml
- Dockerfile
```

### 2. App Runnerサービス作成

AWS ConsoleまたはCLIでApp Runnerサービスを作成：

```bash
aws apprunner create-service \
  --service-name dify-app \
  --source-configuration '{
    "AutoDeploymentsEnabled": true,
    "CodeRepository": {
      "RepositoryUrl": "https://github.com/your-username/dify-apprunner",
      "SourceCodeVersion": {
        "Type": "BRANCH",
        "Value": "main"
      },
      "CodeConfiguration": {
        "ConfigurationSource": "REPOSITORY"
      }
    }
  }'
```

### 3. 環境変数の設定

App Runnerコンソールで以下の環境変数を設定：

**必須設定：**
- `SECRET_KEY`: ランダムな秘密鍵
- `DB_HOST`: RDSエンドポイント
- `DB_PASSWORD`: データベースパスワード
- `REDIS_HOST`: ElastiCacheエンドポイント
- `REDIS_PASSWORD`: Redisパスワード

**URL設定：**
- `APP_WEB_URL`: App RunnerのURL
- `CONSOLE_WEB_URL`: App RunnerのURL
- `API_URL`: App RunnerのURL

### 4. データベース初期化

初回デプロイ後、データベーステーブルを作成：

```bash
# App Runnerコンテナ内で実行
flask db upgrade
```

## セキュリティ設定

### VPC設定
App RunnerをVPC内に配置する場合：

```bash
aws apprunner create-vpc-connector \
  --vpc-connector-name dify-vpc-connector \
  --subnets subnet-12345,subnet-67890 \
  --security-groups sg-abcdef
```

### IAM設定
App Runner用のIAMロールを作成し、必要な権限を付与。

## 監視

- CloudWatch Logsでログ確認
- CloudWatch Metricsでパフォーマンス監視
- ヘルスチェックエンドポイント: `/health`

## トラブルシューティング

### よくある問題

1. **データベース接続エラー**
   - RDSのセキュリティグループ設定確認
   - VPC設定確認

2. **Redis接続エラー**
   - ElastiCacheのセキュリティグループ設定確認
   - VPC設定確認

3. **起動エラー**
   - 環境変数設定確認
   - CloudWatch Logsでエラー詳細確認