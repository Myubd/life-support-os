# セキュリティ修正メモ: バックエンド個別ポートの直接公開について

## 何が問題だったか

`life-support-os-gateway` は `auth.py` で「唯一の入口」として認証(Cookieベースの
共有シークレット)を一手に引き受ける設計になっている。一方で `docker-compose.yml`
は `archlife_backend`(8080) / `interview_backend`(8000) / `study_support`(8100) /
`health_support`(8200) をそれぞれ個別にホストへポート公開しており、かつ
`study-support` / `health-support` には認証コードが一切無かった。

結果として:

- `http://localhost:3000`(gateway)経由 → 認証あり
- `http://localhost:8200`(health-support)に直接アクセス → **認証なしで
  `sensitivity_level: high` の健康データに到達できる**

さらにDocker Desktop(WSL2バックエンド)はデフォルトでポートを `0.0.0.0` に
bindするため、同一LAN上の別端末からも到達し得る状態だった。これは
「クラウドに個人データを送らない」という設計思想の手前で、**同じネットワーク上の
第三者に見られる**という、より基本的な問題。

## 対応内容

1. **`docker-compose.yml`**: 4サービスのポートを `127.0.0.1:PORT:PORT` に変更。
   同一マシン上での直接デバッグ/個別フロントエンドからのアクセスは維持しつつ、
   LANからの到達を遮断する。
2. **`study-support` / `health-support`**: gatewayの `auth.py` と同じ
   共有シークレット(`GATEWAY_AUTH_TOKEN`)によるCookie検証を追加。
   gateway経由のリクエストは `gw_session` Cookieがそのまま転送されるため
   (`_proxy()` がヘッダーを転送する)、gateway経由の動作は変更なし。
   直接ポートへのアクセスのみ、未ログイン状態では401になる。
3. **`archlife_backend` / `interview_backend`**: このリポジトリの管轄外
   (`archlife` / `interview_app` は別リポジトリ)のため、今回はポート制限のみ。
   同様の共有シークレット認証をこの2つのバックエンドにも追加することを推奨。
   (`life-support-os-gateway/auth.py` の `_is_authenticated` 相当のロジックを
   移植するだけで対応可能)

## 残タスク

- `archlife` / `interview_app` 側にも同じCookie検証を追加する
- 本番相当の環境(自宅サーバー等での常時稼働)ではリバースプロキシでTLS終端し、
  `GATEWAY_COOKIE_SECURE=true` を設定することを検討する
