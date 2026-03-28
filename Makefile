DB_HOST=db
DB_PORT=3306
DB_USER=root
DB_PASS=password
DB_NAME=mydb

.PHONY: db-up db-down db-migrate-dry db-migrate db-seed

# MySQLコンテナを起動する
db-up:
	docker compose up -d db

# MySQLコンテナを停止する
db-down:
	docker compose down

# schema.sql との差分を確認する（適用はしない）
db-migrate-dry:
	docker compose run --rm mysqldef \
		-u $(DB_USER) -p $(DB_PASS) -h $(DB_HOST) -P $(DB_PORT) $(DB_NAME) \
		--dry-run < schema.sql

# schema.sql をDBに適用する
db-migrate:
	docker compose run --rm mysqldef \
		-u $(DB_USER) -p $(DB_PASS) -h $(DB_HOST) -P $(DB_PORT) $(DB_NAME) \
		--apply < schema.sql

# seeds.sql のマスタデータをDBに投入する（冪等：何度実行しても同じ結果になる）
# ※ seeds.sql から行を削除してもDBのレコードは自動削除されない
db-seed:
	docker compose exec -T db \
		mysql -u $(DB_USER) -p$(DB_PASS) $(DB_NAME) < seeds.sql
