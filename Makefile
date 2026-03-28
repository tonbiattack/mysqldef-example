DB_HOST=127.0.0.1
DB_PORT=3307
DB_USER=root
DB_PASS=password
DB_NAME=mydb

.PHONY: db-up db-down db-migrate-dry db-migrate

# MySQLコンテナを起動する
db-up:
	docker compose up -d

# MySQLコンテナを停止する
db-down:
	docker compose down

# schema.sql との差分を確認する（適用はしない）
db-migrate-dry:
	mysqldef -u $(DB_USER) -p $(DB_PASS) -h $(DB_HOST) -P $(DB_PORT) $(DB_NAME) --dry-run < schema.sql

# schema.sql をDBに適用する
db-migrate:
	mysqldef -u $(DB_USER) -p $(DB_PASS) -h $(DB_HOST) -P $(DB_PORT) $(DB_NAME) --apply < schema.sql
