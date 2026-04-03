# AGENTS.md

このディレクトリは個人用のスクリプト、ツール、技術メモ、実験的プロジェクトなどをまとめた雑多なワークスペースです。

## 共通ルール

- 回答・コメント・ドキュメントは日本語で記述する
- 文字コードは UTF-8
- 改行コードは LF

## ローカル環境の保護

- ホームディレクトリ (`~`) 配下のドットファイル・ドットディレクトリは読み取り・変更・削除を行わないこと
- 特に以下は機密情報を含むため、絶対に操作しないこと:
  - `~/.ssh` — SSH鍵・設定
  - `~/.aws` — AWS認証情報
  - `~/.gnupg` — GPG鍵・設定
  - `~/.kube` — Kubernetes設定
  - `~/.docker` — Docker認証情報
  - `~/.gcloud` — Google Cloud認証
  - `~/.npmrc` — npm認証トークン
  - `~/.netrc` — 各種サービス認証情報
  - `~/.terraform.d` — Terraform認証
- シェル設定 (`~/.zshrc`, `~/.bashrc` 等) やGit設定 (`~/.gitconfig`) も変更しないこと
- ツールのバージョン管理 (`~/.asdf` 等) も勝手に操作しないこと
- `~/.config`, `~/.claude`, `~/Library` 等のアプリ設定も同様
- これらの情報が必要な場合は、必ずユーザーに確認してから操作すること

## 外部システム操作の制限

外部システムに対する操作は、原則として**参照系(読み取り)のみ**許可する。
更新・削除・作成などの変更操作は、ユーザーの明示的な許可がない限り行わないこと。

### SSH接続 (踏み台サーバ等)

- 許可: ファイル参照、ログ確認、状態確認系コマンド (`cat`, `ls`, `ps`, `systemctl status` 等)
- 禁止: ファイルの作成・変更・削除、サービスの起動・停止、パッケージの追加・削除
- 接続先や認証情報はサブプロジェクトの `LOCAL-ENV-WORK.md` に従う

### クラウド CLI (AWS CLI, gcloud 等)

- 許可: `describe`, `list`, `get` 等の参照系コマンド
- 禁止: `create`, `update`, `delete`, `put`, `modify`, `terminate` 等の変更系コマンド
- 例: `aws ec2 describe-instances` は可、`aws ec2 terminate-instances` は不可

### データベース CLI (mysql, psql, redis-cli 等)

- 許可: `SELECT`, 読み取り系コマンド
- 禁止: `INSERT`, `UPDATE`, `DELETE`, `DROP`, `ALTER`, `CREATE` 等の変更系

### コンテナ/オーケストレーション (docker, kubectl 等)

- 許可: `inspect`, `logs`, `get`, `describe`, `ps` 等の参照系
- 禁止: `run`, `exec`, `apply`, `delete`, `scale`, `restart` 等の変更系

### IaC (terraform, ansible 等)

- 許可: `plan`, `check`, `validate`, `show` 等の確認系
- 禁止: `apply`, `destroy` 等の実行系

### API呼び出し (curl, httpie 等)

- 許可: `GET` リクエスト
- 禁止: `POST`, `PUT`, `PATCH`, `DELETE` リクエスト

### 共通事項

- 上記の禁止操作が必要な場合は、必ずユーザーに確認し明示的な許可を得ること
- 不明な場合は参照系であっても確認すること

## 認証情報・環境固有設定

- 各サブプロジェクトに `LOCAL-ENV-WORK.md` が存在する場合、接続先や認証情報はそのファイルに従う
- `LOCAL-ENV-WORK.md` は原則として Git 管理しないこと (`.gitignore` に含める)
- ただし、プロジェクトが独自のルールで Git 管理に含めている場合はそのプロジェクトのルールに従う

## 機密情報の取り扱い

- APIキー、パスワード、トークン、シークレット等をソースコードにハードコードしないこと
- 機密情報は環境変数、`.env` ファイル、または `LOCAL-ENV-WORK.md` 等の Git 管理外ファイルで管理する
- `.env` ファイルや機密情報を含むファイルは `.gitignore` に含めること
- コード内に機密情報が含まれていることに気づいた場合は、ユーザーに警告すること

## コスト意識

- 有料 API の呼び出し (OpenAI, Claude API, Google AI 等) は、ユーザーの確認なしに実行しないこと
- クラウドリソースの起動・作成 (EC2インスタンス、Cloud Functions 等) は外部システム操作の制限に準じる
- 大量のリクエストやループ処理で意図せずコストが発生しないよう注意すること

## Git ワークフロー (gitflow)

### ブランチ構成

| ブランチ | 用途 | 派生元 | マージ先 |
|----------|------|--------|----------|
| `main` | 本番リリース (安定版) | — | — |
| `develop` | 開発統合ブランチ | `main` | `main` |
| `feature/*` | 新機能開発 | `develop` | `develop` |
| `release/*` | リリース準備 | `develop` | `main` + `develop` |
| `hotfix/*` | 緊急修正 | `main` | `main` + `develop` |

### ブランチ命名規則

- `feature/簡潔な説明` — 例: `feature/add-deploy-script`
- `release/バージョン` — 例: `release/1.0.0`
- `hotfix/簡潔な説明` — 例: `hotfix/fix-config-path`

### 運用ルール

- 作業は必ず `feature/*` ブランチで行い、`develop` へマージする
- `main` / `develop` ブランチへの直接コミット・直接 push は行わないこと
- マージは原則として Pull Request 経由で行う
- `feature` ブランチは `develop` から派生し、`develop` にマージする
- `main` へのマージは `release/*` または `hotfix/*` 経由のみ

### 破壊的操作の制限

- 以下の操作はユーザーの明示的な許可なしに実行しないこと:
  - `git push --force` / `git push --force-with-lease`
  - `git reset --hard`
  - `git branch -D` (強制削除)
  - `git clean -f`
  - `git checkout .` / `git restore .` (全変更の破棄)
  - `git rebase` (リモートに push 済みのブランチに対して)
- コミット前に差分を確認し、意図しないファイルが含まれていないか注意すること

## プロジェクト構成

- 各サブディレクトリが独立したプロジェクトになり得る
- プロジェクト固有のコーディング規約・技術スタック・ルールは各サブプロジェクト配下の AGENTS.md や設定ファイルで定義する
- トップレベルでは特定の言語やフレームワークを規定しない
