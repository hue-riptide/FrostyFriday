# FrostyFriday

PoCアカウントでの開発

前提

PoCアカウントでの開発においては、Snowsight上のdbt Projects on Snowflakeを利用します。
事前準備

自身のGitHubアカウントでPATを作成する。
Settings > Developer settings > Personal access tokens > Tokens (classic) > Generate new token > Generate new token (classic) を押下。
repo にチェックを入れて、Generate Token を押下。
生成されたPATを控える。
PoCアカウントのSnowsightへログイン。
SnowflakeからGitHubリポジトリにアクセスするためのAPI統合を作成する。
Snowsight ワークシートを開き、以下を実行。

USE ROLE ACCOUNTADMIN;
USE DATABASE SECRET_DATABASE;
USE SCHEMA SECRET_SCHEMA;

CREATE ROLE <任意のロール名>;
GRANT USAGE ON DATABASE SECRET_DATABASE TO ROLE <任意のロール名>;
GRANT USAGE ON SCHEMA SECRET_SCHEMA TO ROLE <任意のロール名>;
GRANT CREATE SECRET ON SCHEMA SECRET_SCHEMA TO ROLE <任意のロール名>;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE <任意のロール名>;
GRANT ROLE <任意のロール名> TO USER <自身のユーザ名>;

USE ROLE <任意のロール名>;
CREATE OR REPLACE SECRET <任意のシークレット名>
  TYPE = PASSWORD
  USERNAME = "<自身のGitHubユーザ名>"
  PASSWORD = "<1.で控えたPAT>"
;

CREATE OR REPLACE API INTEGRATION <任意のAPI統合名>
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/Soba-Noodles/snowflake_dbt_projects.git')
  ALLOWED_AUTHENTICATION_SECRETS = (<任意のシークレット名>)
  ENABLED = TRUE
;
開発

Snowsightのワークスペースへ接続。
左上のプロジェクト名を押下。
Gitリポジトリからを押下。
以下の通り入力し、作成を押下。
リポジトリURL：https://github.com/Soba-Noodles/snowflake_dbt_projects.git
API統合：<事前準備で作成したAPI統合名>
データベース：SECRET_DATABASE
スキーマ：SECRET_SCHEMA
シークレットを選択：<事前準備で作成したシークレット名>
変更を押下し、ブランチを作成。
エディター上部のProfileを押下し、プルダウンから poc を選択。
profiles.yml に、利用するRole等の情報を適宜入力。
models 配下に適宜モデルを作成。
selectors.yml を編集し、デプロイするモデルを設定。
エディター上部のプルダウンより「実行」を選択し、実行ボタンを押下。
