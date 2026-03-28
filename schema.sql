-- スキーマ定義ファイル
-- このファイルがDBの「あるべき姿」を表す
-- mysqldef で差分検出・適用するための定義ファイル

CREATE TABLE users (
    id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100)    NOT NULL,
    email      VARCHAR(255)    NOT NULL,
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_email (email)
);

-- 区分値マスタ（seeds.sql でデータを投入する）
CREATE TABLE status_types (
    code       TINYINT UNSIGNED NOT NULL PRIMARY KEY,
    name       VARCHAR(50)      NOT NULL
);

CREATE TABLE posts (
    id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT UNSIGNED NOT NULL,
    title      VARCHAR(255)    NOT NULL,
    body       TEXT            NOT NULL,
    created_at DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id)
);
