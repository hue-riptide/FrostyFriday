# FrostyFriday

PoCアカウントでの開発

前提

PoCアカウントでの開発においては、Snowsight上のdbt Projects on Snowflakeを利用します。
# 事前準備

1. 自身のGitHubアカウントでPATを作成する。
    - Settings > Developer settings > Personal access tokens > Tokens (classic) > Generate new token > Generate new token (classic) を押下。
    - repo にチェックを入れて、Generate Token を押下。
    - 生成されたPATを控える。
2. PoCアカウントのSnowsightへログイン。
3. SnowflakeからGitHubリポジトリにアクセスするためのAPI統合を作成する。


Snowsight ワークシートを開き、以下を実行。
```
USE ROLE ACCOUNTADMIN;
create or replace database secret_database;
create or replace schema secret_database.secret_schema;
USE DATABASE SECRET_DATABASE;
USE SCHEMA SECRET_SCHEMA;

CREATE ROLE role_frostyfriday;
GRANT USAGE ON DATABASE SECRET_DATABASE TO ROLE role_frostyfriday;
GRANT USAGE ON SCHEMA SECRET_SCHEMA TO ROLE role_frostyfriday;
GRANT CREATE SECRET ON SCHEMA SECRET_SCHEMA TO ROLE role_frostyfriday;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE role_frostyfriday;
GRANT ROLE role_frostyfriday TO USER hue;

USE ROLE role_frostyfriday;
CREATE OR REPLACE SECRET ff_secret
  TYPE = PASSWORD
  USERNAME = "hue-riptide"
  PASSWORD = "<1.で控えたPAT>"
;

CREATE OR REPLACE API INTEGRATION ff_hue
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/hue-riptide/FrostyFriday.git')
  ALLOWED_AUTHENTICATION_SECRETS = (ff_secret)
  ENABLED = TRUE
;
```

# 開発

1. Snowsightのワークスペースへ接続。
2. 左上のプロジェクト名を押下。
3. Gitリポジトリからを押下。
4. 以下の通り入力し、作成を押下。
    - リポジトリURL：https://github.com/hue-riptide/FrostyFriday.git
    - API統合：<事前準備で作成したAPI統合名>
    - データベース：SECRET_DATABASE
    - スキーマ：SECRET_SCHEMA
    - シークレットを選択：<事前準備で作成したシークレット名>
5. 変更を押下し、ブランチを作成。
6. エディター上部のProfileを押下し、プルダウンから poc を選択。
7. `profiles.yml` に、利用するRole等の情報を適宜入力。
8. `models` 配下に適宜モデルを作成。
9. `selectors.yml` を編集し、デプロイするモデルを設定。
10. エディター上部のプルダウンより「実行」を選択し、実行ボタンを押下。
