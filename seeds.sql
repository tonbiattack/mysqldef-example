-- マスタデータ投入ファイル
-- 何度実行しても同じ結果になるよう ON DUPLICATE KEY UPDATE で冪等に書く
-- ※ このファイルから行を削除してもDBのレコードは自動削除されない

set names utf8mb4;
-- ステータス区分値マスタ
INSERT INTO status_types (code, name) VALUES
    (1, '受付'),
    (2, '処理中'),
    (3, '完了'),
    (4, '停止')
ON DUPLICATE KEY UPDATE name = VALUES(name);
