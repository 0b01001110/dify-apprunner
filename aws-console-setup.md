# AWS コンソールでのDify App Runner セットアップ手順

## 1. GitHub接続の作成

1. **App Runnerコンソール**にアクセス
   - https://console.aws.amazon.com/apprunner/

2. **接続を作成**
   - 左メニューの「GitHub connections」をクリック
   - 「Create GitHub connection」をクリック
   - 接続名: `dify-github-connection`
   - 「Connect to GitHub」をクリック
   - GitHubアカウント認証を完了

## 2. App Runnerサービスの作成

1. **サービス作成**
   - App Runnerコンソールで「Create service」
   - ソースタイプ: **Repository**

2. **リポジトリ設定**
   - Connection: `dify-github-connection`
   - Repository URL: `https://github.com/0b01001110/dify-apprunner`
   - Branch: `main`
   - Automatic deployment: **Yes**

3. **ビルド設定**
   - Configuration source: **Use a configuration file**
   - Configuration file: `apprunner.yaml`

4. **サービス設定**
   - Service name: `dify-app`
   - Virtual CPU: **1 vCPU**
   - Virtual memory: **2 GB**

5. **環境変数（後で設定）**
   ```
   SECRET_KEY=<ランダム文字列>
   DB_HOST=<RDSエンドポイント>
   DB_PASSWORD=<DBパスワード>
   REDIS_HOST=<ElastiCacheエンドポイント>
   REDIS_PASSWORD=<Redisパスワード>
   ```

## 3. RDS PostgreSQLの作成

1. **RDSコンソール**にアクセス
   - https://console.aws.amazon.com/rds/

2. **データベース作成**
   - 「Create database」
   - Engine: **PostgreSQL**
   - Version: **15.4**
   - Template: **Free tier** (テスト用)

3. **設定**
   - DB instance identifier: `dify-postgres`
   - Master username: `postgres`
   - Master password: `<強いパスワード>`
   - DB name: `dify`

4. **接続設定**
   - Public access: **Yes**（テスト用）
   - VPC security group: 新規作成
   - Port: **5432**

## 4. ElastiCache Redisの作成

1. **ElastiCacheコンソール**にアクセス
   - https://console.aws.amazon.com/elasticache/

2. **Redisクラスター作成**
   - 「Create Redis cluster」
   - Cluster mode: **Disabled**
   - Node type: **cache.t3.micro**

3. **設定**
   - Name: `dify-redis`
   - Port: **6379**
   - Parameter group: **default.redis7**

## 5. セキュリティグループの設定

### RDS用セキュリティグループ
- **Inbound rules:**
  - Type: PostgreSQL
  - Port: 5432
  - Source: App Runner security group

### ElastiCache用セキュリティグループ
- **Inbound rules:**
  - Type: Custom TCP
  - Port: 6379
  - Source: App Runner security group

## 6. App Runnerの環境変数設定

サービス作成後、以下を設定：

```
SECRET_KEY=<64文字のランダム文字列>
DB_HOST=<RDSエンドポイント>
DB_PASSWORD=<RDSパスワード>
REDIS_HOST=<ElastiCacheエンドポイント>
REDIS_PASSWORD=<Redisパスワード（設定した場合）>
APP_WEB_URL=<App RunnerのURL>
CONSOLE_WEB_URL=<App RunnerのURL>
API_URL=<App RunnerのURL>
```

## 7. データベース初期化

初回デプロイ後：
1. App Runnerのログを確認
2. 必要に応じてデータベースマイグレーション実行

## トラブルシューティング

- App Runnerログ: CloudWatch Logsで確認
- データベース接続: セキュリティグループとVPC設定確認
- Redis接続: ElastiCacheエンドポイントとポート確認