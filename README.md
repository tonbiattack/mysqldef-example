# mysqldef-example

mysqldef を使ったスキーマ管理のサンプルプロジェクトです。

## 構成

```
mysqldef-example/
├── schema.sql          # スキーマ定義（DBの「あるべき姿」）
├── docker-compose.yml  # ローカルMySQL環境
├── Makefile            # 操作コマンド
└── README.md
```

## 前提

- Docker がインストールされていること

mysqldef はDockerコンテナとして実行するため、ローカルへのインストールは不要です。

## 使い方

### 1. MySQLを起動する

```bash
# Makefile
make db-up

# 素のコマンド
docker compose up -d
```

コンテナの起動後、ヘルスチェックが通るまで少し待ちます。

### 2. 差分を確認する（dry-run）

```bash
# Makefile
make db-migrate-dry

# 素のコマンド
docker compose run --rm mysqldef \
  -u root -p password -h db -P 3306 mydb \
  --dry-run < schema.sql
```

実際にSQLを適用せず、どんな変更が実行されるかを確認できます。
初回は `CREATE TABLE` 文が表示されます。

### 3. スキーマを適用する

```bash
# Makefile
make db-migrate

# 素のコマンド
docker compose run --rm mysqldef \
  -u root -p password -h db -P 3306 mydb \
  --apply < schema.sql
```

`schema.sql` の内容がDBに反映されます。
現在のバージョンでは `--apply` を省略してもデフォルトで適用されますが、将来のバージョンでは必須になる予定のため、明示して付ける方が安全です。

### 4. マスタデータを投入する

```bash
# Makefile
make db-seed

# 素のコマンド
docker compose exec db mysql -u root -ppassword mydb < seeds.sql
```

`seeds.sql` のデータがDBに反映されます。
`ON DUPLICATE KEY UPDATE` で冪等に書かれているため、何度実行しても同じ結果になります。

`seeds.sql` に行を追加・変更した場合は次の実行時に反映されます。
ただし `seeds.sql` から行を削除してもDBのレコードは自動削除されません。削除が必要な場合は手動でDELETE文を実行してください。

### 5. カラムを追加してみる

`schema.sql` の `users` テーブルに `deleted_at` を追記します。

```sql
CREATE TABLE users (
    id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)    NOT NULL,
    email      VARCHAR(255)    NOT NULL,
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME,
    UNIQUE KEY uq_email (email)
);
```

差分を確認すると `ALTER TABLE` が生成されます。

```bash
# Makefile
make db-migrate-dry

# 素のコマンド
docker compose run --rm mysqldef \
  -u root -p password -h db -P 3306 mydb \
  --dry-run < schema.sql
# -- dry run --
# ALTER TABLE `users` ADD COLUMN `deleted_at` datetime;
```

問題なければ適用します。

```bash
# Makefile
make db-migrate

# 素のコマンド
docker compose run --rm mysqldef \
  -u root -p password -h db -P 3306 mydb \
  --apply < schema.sql
```

## 注意点

### DROP系の変更には `--enable-drop` が必要

mysqldefはデフォルトで `DROP TABLE` や `DROP COLUMN` を適用しません。
`schema.sql` からカラムを削除しても、`--enable-drop` を付けなければ変更は無視されます。

本番環境でDROP系を適用する場合は、必ず `--dry-run` で内容を確認してから実行してください。

```bash
docker compose run --rm mysqldef \
  -u root -p password -h db -P 3306 mydb \
  --dry-run --enable-drop < schema.sql
```

### 変更履歴はGitで管理する

mysqldefはFlyway と異なり、適用履歴をDB側に持ちません。
`schema.sql` をGitでコミットしていくことが変更履歴の管理になります。
