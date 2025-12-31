# Google Maps API 設定ガイド

## 1. Google Maps APIキーの取得

### ステップ1: Google Cloud Consoleにアクセス
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクトを作成または選択

### ステップ2: Maps JavaScript APIを有効化
1. 左メニューから「APIとサービス」→「ライブラリ」を選択
2. 「Maps JavaScript API」を検索して選択
3. 「有効にする」ボタンをクリック

### ステップ3: APIキーを作成
1. 左メニューから「APIとサービス」→「認証情報」を選択
2. 「認証情報を作成」→「APIキー」をクリック
3. APIキーが生成されるので、コピーして保存

### ステップ4: APIキーの制限設定（推奨）
1. 作成したAPIキーの「編集」をクリック
2. 「アプリケーションの制限」で「HTTPリファラー」を選択
3. 以下のリファラーを追加:
   - `localhost:3000/*` (開発環境)
   - `*.onrender.com/*` (本番環境、Renderの場合)
   - 自分のドメイン `yourdomain.com/*` (独自ドメインの場合)
4. 「API の制限」で「キーを制限」を選択し、「Maps JavaScript API」のみにチェック
5. 「保存」をクリック

---

## 2. 開発環境での設定

### Docker環境の場合

#### `.env` ファイルに追加
プロジェクトルートの `.env` ファイルに以下を追加:

```bash
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

**注意**: `.env` ファイルは `.gitignore` に含まれているため、Gitにはコミットされません。

#### Dockerコンテナを再起動
```bash
docker-compose down
docker-compose up -d
```

---

## 3. 本番環境での設定（Render）

### Renderダッシュボードで環境変数を設定

1. [Render Dashboard](https://dashboard.render.com/) にログイン
2. 対象のWebサービスを選択
3. 左メニューから「Environment」を選択
4. 「Add Environment Variable」をクリック
5. 以下を追加:
   - **Key**: `GOOGLE_MAPS_API_KEY`
   - **Value**: 取得したAPIキー
6. 「Save Changes」をクリック

Renderが自動的にアプリケーションを再デプロイします。

---

## 4. 動作確認

### 開発環境での確認
1. 位置情報付きの投稿を作成
2. 投稿詳細画面にアクセス
3. Google Mapが表示されることを確認
4. マーカーが正しい位置に表示されることを確認

### 本番環境での確認
1. デプロイが完了したら、本番環境のURLにアクセス
2. 開発環境と同様に動作確認

---

## 5. トラブルシューティング

### マップが表示されない場合

#### エラー: "This page can't load Google Maps correctly"
- APIキーが正しく設定されているか確認
- APIキーの請求が有効になっているか確認（無料枠があります）
- Maps JavaScript APIが有効化されているか確認

#### エラー: "RefererNotAllowedMapError"
- APIキーの「HTTPリファラー」制限を確認
- リファラーに現在のドメインが含まれているか確認

#### マップは表示されるがマーカーが表示されない
- 投稿に緯度経度が保存されているか確認
- ブラウザのコンソールでエラーを確認

#### 開発環境で動作するが本番環境で動作しない
- Renderの環境変数が正しく設定されているか確認
- APIキーの制限設定に本番環境のドメインが含まれているか確認

---

## 6. コスト

Google Maps APIは**月$200の無料クレジット**があります。

### Maps JavaScript APIの料金
- マップの読み込み: 1,000回あたり $7
- 月28,500回まで無料（$200クレジット ÷ $7 × 1,000）

個人開発や小規模アプリであれば、無料枠内で十分に運用可能です。

詳細は[Google Maps Platform料金](https://mapsplatform.google.com/pricing/)を参照してください。

---

## 7. 参考リンク

- [Google Maps JavaScript API ドキュメント](https://developers.google.com/maps/documentation/javascript)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Google Maps Platform 料金](https://mapsplatform.google.com/pricing/)

