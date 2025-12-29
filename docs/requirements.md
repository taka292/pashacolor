# パシャから - 色がテーマのお出かけ共有アプリ

## プロジェクト概要

### アプリ名

パシャから（Pashakara）

### コンセプト

毎日色のお題が出され、その色に合った写真を撮って投稿するお出かけ共有アプリ。色を通じて日常に彩りを加え、想い出を記録する。

### ターゲットユーザー

- 休日にあまり予定がないけど、どこかお出かけしたいカップル
- 独身で日々に彩りがなくて悩んでいる人

---

## 技術スタック

### バックエンド

- **フレームワーク**: Rails 8.1.1
- **データベース**: PostgreSQL
- **認証**: Devise
- **画像ストレージ**: Active Storage（開発環境: ローカル、本番環境: S3）

### フロントエンド

- **CSS**: TailwindCSS v4
- **JavaScript**: Stimulus（Hotwire）
- **ページ遷移**: Turbo（Hotwire）
- **レスポンシブ**: モバイルファースト

### インフラ

- **開発環境**: Docker + Docker Compose
- **本番環境**: Render
- **ジョブキュー**: Solid Queue（Rails 8 標準） ※現状使用予定なし

### 外部 API 連携（要検討）

- **GPS 座標取得**: ブラウザの Geolocation API（標準機能、API キー不要）※MVP で使用
- **位置情報 API**: Google Maps API ※Phase 2 で実装（マップ表示機能で使用、地図上に投稿をピンで表示）
- **天気 API**: OpenWeatherMap API / Weather API ※MVP リリースには含めない
- **画像解析 API（色抽出）**: Cloud Vision API / 独自実装 ※MVP リリースには含めない

---

## コア機能

### 1. ユーザー認証・プロフィール機能

#### 要件（要明確化）

- [x] 認証方式の決定（Devise）
- [x] ソーシャルログインの有無（Google）※ or メールアドレス パスワード
- [x] プロフィール情報（名前、アイコン、自己紹介）
- [x] ペア機能（カップル向け）の実装方法 ※mvp リリースには含めない

#### データモデル

```
User
- id
- email (string)
- password_digest (string)
- name (string)
- avatar (Active Storage)
- created_at
- updated_at

# ペア機能用（要検討）※mvpリリースには含めない
Pair
- id
- user1_id (references)
- user2_id (references)
- created_at
- updated_at
```

---

### 2. 色のお題機能（マスタテーブル）

#### 機能概要

- 毎日 1 つの色のお題が自動生成される（オンデマンド生成、日替わりでランダム）
- 過去 12 日間で色が被らないようにする（すべて出し切ったら次のサイクル）
- 色は DB のマスタテーブル（ColorTheme）で管理（12 色の色相環）
- ユーザーは色相環から色を選択して投稿
- 初期データとして 12 色の色相環を投入

#### 初期色のリスト（12 色の色相環）

1. **黄** (Kiiro) - Yellow
2. **黄緑** (Kimidori) - Yellow-Green
3. **緑** (Midori) - Green
4. **青緑** (Aomidori) - Blue-Green
5. **青** (Ao) - Blue
6. **青紫** (Aomurasaki) - Blue-Violet
7. **紫** (Murasaki) - Violet
8. **赤紫** (Akamurasaki) - Red-Violet
9. **赤** (Aka) - Red
10. **赤橙** (Akadaidai) - Red-Orange
11. **橙** (Daidai) - Orange
12. **黄橙** (Kidaidai) - Yellow-Orange

#### 要件（要明確化）

- [x] お題の色の種類と定義（12 色の色相環）
- [x] お題の生成ロジック（オンデマンド生成、過去 12 日間で色が被らない、すべて出し切ったら次のサイクル）
- [x] お題の有効期限（1 日）
- [x] 過去のお題の閲覧可否（表示しない、今日のお題のみ表示）
- [x] お題の難易度設定の有無 ※mvp では難易度含めない

#### データモデル

```
ColorTheme（マスタテーブル）
- id
- color_name (string) # 例: "黄", "黄緑", "緑", "青緑", "青", "青紫", "紫", "赤紫", "赤", "赤橙", "橙", "黄橙"
- color_code (string) # HEX形式: "#FFFF00"
- rgb_r (integer) # RGB値のR成分
- rgb_g (integer) # RGB値のG成分
- rgb_b (integer) # RGB値のB成分
- description (text) # 色の説明文
- is_active (boolean, default: true) # 有効/無効フラグ
- display_order (integer) # 表示順序（色相環の順序）
- created_at
- updated_at

# 毎日のお題を管理するテーブル
DailyTheme
- id
- color_theme_id (references)
- theme_date (date, unique: true) # 日付（ユニーク制約）
- description (text, nullable) # その日のお題の説明文（オプション）
- created_at
- updated_at

# インデックス
- index_daily_themes_on_theme_date (theme_date)
- index_daily_themes_on_color_theme_id (color_theme_id)
```

#### 自動生成ロジック

##### MVP 実装: オンデマンド生成（バッチジョブ不要）

- **実装方式**: 今日のお題を取得する際に、存在しなければ自動生成
- **生成タイミング**: ユーザーがトップページにアクセスした際に自動生成
- **生成方法**:
  1. 今日の日付で`DailyTheme`を検索
  2. 存在しない場合、過去 12 日間で使用された色を取得
  3. 使用されていない色の中からランダムに 1 色を選択
  4. すべての色が使用済みの場合は、全色からランダムに選択（次のサイクル）
  5. 選択した色で`DailyTheme`を作成

**実装例**:

```ruby
# app/models/daily_theme.rb
class DailyTheme < ApplicationRecord
  belongs_to :color_theme

  # 今日のお題を取得（存在しなければ自動生成）
  def self.today_theme
    today = Date.current
    theme = find_by(theme_date: today)

    return theme if theme.present?

    # 今日のお題が存在しない場合は自動生成
    create_today_theme
  end

  private

  def self.create_today_theme
    today = Date.current

    # 過去12日間で使用された色を取得
    used_color_ids = where(theme_date: (today - 11.days)..today)
                     .pluck(:color_theme_id)

    # 使用されていない色を取得
    available_colors = ColorTheme.where.not(id: used_color_ids).active

    # すべて使用済みの場合は、全色から選択（次のサイクル）
    available_colors = ColorTheme.active if available_colors.empty?

    # ランダムに1色を選択
    selected_color = available_colors.sample

    create!(
      color_theme_id: selected_color.id,
      theme_date: today
    )
  end
end
```

**コントローラーでの使用例**:

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @today_theme = DailyTheme.today_theme
  end
end
```

##### 将来実装: バッチジョブ（オプション）

- **バッチジョブ**: 毎日深夜（例: 0:00）に翌日のお題を事前生成
- **メリット**: 事前生成により、初回アクセス時のレスポンス向上
- **実装方法**: Rails の Active Job + Solid Queue（または cron job）

---

### 3. 投稿機能

#### 機能概要

- 写真をアップロードして投稿（任意）
- 写真なしでも投稿可能
- 位置情報の記録（任意：GPS 座標（Geolocation API）またはテキスト入力「家」「カフェ」など）
- ユーザーが色相環から色を選択して投稿（必須）
- コメント・説明文の追加（任意）
- 投稿した色でカラーパレットが埋まる
- **記録した投稿は無制限で閲覧可能**（過去のお題は表示しないが、投稿した内容は閲覧可能）

#### 要件（要明確化）

- [x] 写真の任意（写真なしでも投稿可能）
- [x] 位置情報の取得方法（GPS 座標: Geolocation API で取得、テキスト入力: 「家」「カフェ」など手動入力）
- [x] 位置情報の公開範囲（非公開）※後に旅行先とかの写真は公開できるようにとかはするかも
- [x] 色の選択方法（ユーザーが色相環から手動で選択、必須、円形 UI で自然な選択）
- [x] 記録した投稿の閲覧（無制限で閲覧可能、過去のお題は表示しないが投稿内容は閲覧可能）
- [x] 投稿の編集・削除機能
- [x] 投稿の公開範囲（MVP の段階では一旦非公開）

#### バリデーション

- **必須**: `color_theme_id`（色の選択）
- **任意**: `image`（写真）、`description`（説明文）、`latitude`/`longitude`（GPS 座標）、`location_name`（テキスト入力）

#### データモデル

```
Post
- id
- user_id (references)
- color_theme_id (references, null: false) # ユーザーが選択した色（必須）
- image (Active Storage, nullable) # 写真（任意）
- description (text, nullable) # 投稿の説明文（任意）
- latitude (decimal, nullable) # GPS座標（Geolocation APIで取得、任意）
- longitude (decimal, nullable) # GPS座標（Geolocation APIで取得、任意）
- location_name (string, nullable) # テキスト入力のみ（「家」「カフェ」など、任意）
- is_public (boolean, default: false) # MVPでは非公開
- posted_at (datetime)
- created_at
- updated_at

# インデックス
- index_posts_on_user_id (user_id)
- index_posts_on_color_theme_id (color_theme_id)
- index_posts_on_posted_at (posted_at)
```

---

### 4. カラーパレット機能

#### 機能概要

- 投稿した色でカラーパレットが埋まる
- ユーザーの色の履歴を可視化
- カラーパレットの色は、Post テーブルの color_theme_id から取得（ColorTheme マスタテーブルを参照）
- 円形の色相環で全 12 色を表示し、投稿した色のみ彩度がある（投稿していない色はグレーアウト）

#### 要件（明確化済み）

- [x] パレットの表示形式（円形の色相環、12 色を円形に配置）
- [x] パレットのサイズ（全 12 色を表示、投稿した色のみ彩度がある、投稿していない色はグレーアウト）
- [x] パレットの共有機能（MVP では不要）
- [x] パレットのエクスポート機能（MVP では含めない）
- [x] 色の並び順（色相環順、display_order 順）
- [x] 色のサイズ（すべて同じサイズ）
- [x] クリック時の動作（その色の投稿一覧を表示）

#### データモデル

```
# カラーパレットはPostテーブルから動的に生成するため、専用テーブルは不要
# Postテーブルのcolor_theme_idを集計して、ColorThemeマスタテーブルから色情報を取得
# 必要に応じて、パフォーマンス向上のためにキャッシュテーブルを検討

ColorPaletteCache（オプション：パフォーマンス向上用）
- id
- user_id (references)
- color_theme_id (references)
- post_count (integer) # その色の投稿数
- last_posted_at (datetime) # 最後に投稿した日時
- created_at
- updated_at
```

### 5. スタンプ・メダル機能 ※MVP には含めない

#### 機能概要

- お題をクリアするとスタンプが獲得できる
- 1 週間で 7 色集めると虹メダル獲得
- 達成感を演出

#### 要件（要明確化）

- [ ] スタンプの種類とデザイン
- [ ] メダルの種類（虹メダル以外にもあるか）
- [ ] スタンプ/メダルの表示方法
- [ ] 連続達成の記録（ストリーク機能）
- [ ] スタンプ/メダルの共有機能

#### データモデル

```
Stamp
- id
- user_id (references)
- color_theme_id (references)
- post_id (references)
- earned_at (datetime)
- created_at
- updated_at

Medal
- id
- user_id (references)
- medal_type (string) # "rainbow", "perfect_week", etc.
- earned_at (datetime)
- created_at
- updated_at
```

---

### 6. アルバム機能 ※MVP には含めない

#### 機能概要

- 色ごとの思い出アルバム
- 投稿を色別に閲覧できる

#### 要件（要明確化）

- [ ] アルバムの表示形式（グリッド / リスト）
- [ ] アルバムの並び順（日付順 / 人気順）
- [ ] アルバムのフィルタリング機能
- [ ] アルバムの共有機能

#### データモデル

```
# Postモデルで色別にフィルタリング可能なため、追加テーブルは不要かも
# ただし、アルバムのメタ情報が必要な場合は以下を検討
Album
- id
- user_id (references)
- color_theme_id (references)
- name (string)
- description (text)
- created_at
- updated_at
```

---

## 発展機能 ※mvp には含めない

### 8. ペアクエスト機能（カップル向け）

#### 機能概要

- 2 人で同じ色を探す「ペアクエスト」
- ペアで協力してクリアする楽しさ

#### 要件（要明確化）

- [ ] ペアの登録方法
- [ ] ペアクエストの開始方法
- [ ] ペアクエストの達成条件（2 人とも同じ色を投稿？）
- [ ] ペアクエストの報酬（通常のスタンプとは別？）

#### データモデル

```
PairQuest
- id
- pair_id (references)
- color_theme_id (references)
- status (string) # "active", "completed", "expired"
- started_at (datetime)
- completed_at (datetime)
- created_at
- updated_at
```

---

### 9. 位置情報連携機能

#### 機能概要

- 位置情報から周辺のおすすめ色スポットを AI レコメンド
- 「今日は〇〇駅でお出かけするとポイントアップ!」機能

#### 要件（要明確化）

- [ ] 位置情報 API の選定（Google Maps API に決定）
- [ ] スポットレコメンドのロジック（AI / ルールベース）
- ポイントアップの計算方法
- [ ] 位置情報の精度（駅単位 / 建物単位）
- [ ] プライバシー設定（位置情報の保存期間）

#### データモデル

```
LocationRecommendation
- id
- user_id (references)
- latitude (decimal)
- longitude (decimal)
- location_name (string)
- recommended_color (string)
- point_bonus (integer)
- expires_at (datetime)
- created_at
- updated_at
```

---

### 10. 天気連動機能

#### 機能概要

- 天気 API を使い、晴れの日は"青空フォト"推し、雨の日は"透明や水滴"など

#### 要件（要明確化）

- [ ] 天気 API の選定（OpenWeatherMap / Weather API）
- [ ] 天気と色のマッピング（晴れ → 青、雨 → 透明/水滴、曇り →？）
- [ ] 天気情報の更新頻度
- [ ] 天気連動のお題の優先度（通常のお題より優先？）

#### データモデル

```
WeatherTheme
- id
- weather_condition (string) # "sunny", "rainy", "cloudy"
- color_theme_id (references)
- priority (integer)
- created_at
- updated_at
```

---

---

### 11. マップ表示機能（投稿の位置情報可視化）

#### 機能概要

- Google Maps API を使用して、投稿した写真をマップ上にピンで表示
- 位置情報がある投稿のみをマップ上に表示
- カスタムマーカー（色相環の色を使用）で投稿を識別
- マーカーをクリックすると、投稿の写真と説明を表示

#### 要件（明確化済み）

- [x] マップ表示（Google Maps API を使用）
- [x] カスタムマーカー（色相環の色を使用して投稿を識別）
- [x] 情報ウィンドウ（投稿写真と説明を表示）
- [x] 表示対象（位置情報がある投稿のみ）
- [x] プライバシー（MVP では自分の投稿のみ表示、非公開）

#### 実装方法

- **バックエンド**: Rails コントローラーで位置情報がある投稿を JSON 形式で返す
- **フロントエンド**: Stimulus コントローラーで Google Maps API を統合
- **マーカー**: 色相環の色（`color_theme.color_code`）を使用したカスタムマーカー
- **データ取得**: `/posts/map_data.json` エンドポイントから投稿データを取得

#### データモデル

```
# Postテーブルの既存カラムを使用
Post
- latitude (decimal, nullable) # GPS座標
- longitude (decimal, nullable) # GPS座標
- color_theme_id (references) # マーカーの色に使用
- image (Active Storage) # 情報ウィンドウで表示
- description (text) # 情報ウィンドウで表示

# 追加のインデックス（パフォーマンス向上）
- index_posts_on_latitude_and_longitude (latitude, longitude)
```

#### 実装の流れ

1. Google Maps API キーの取得と設定
2. Stimulus コントローラーでマップを初期化
3. 投稿データを JSON 形式で取得する API エンドポイントを作成
4. カスタムマーカー（色相環の色）を作成
5. 情報ウィンドウで投稿写真と説明を表示
6. ナビゲーションにマップタブを追加

#### 実装難易度

- **難易度**: 中程度
- **理由**: Google Maps API の統合は標準的で、Rails + Stimulus で実装可能
- **注意点**:
  - 位置情報が任意のため、位置情報がない投稿は表示されない
  - API キーの管理が必要
  - 投稿数が多い場合はクラスタリングを検討

#### 将来の拡張

- クラスタリング（投稿数が多い場合）
- フィルタリング（色別、日付別）
- 周辺スポット検索との連携

---

## UI/UX 要件（要明確化）

### 画面構成

- [ ] トップページ（今日のお題表示、円形の色相環から色選択）
- [ ] 投稿一覧ページ（自分の投稿を無制限で閲覧可能）
- [ ] 投稿詳細ページ
- [ ] プロフィールページ
- [ ] カラーパレットページ（円形の色相環で全 12 色を表示、投稿した色のみ彩度がある、クリックで投稿一覧表示）
- [ ] マップページ（投稿の位置情報をマップ上に表示、カスタムマーカーで色を識別）※MVP には含めない（Phase 2 で実装）
- [ ] アルバムページ（色別）※MVP には含めない
- [ ] スタンプ/メダル一覧ページ ※MVP には含めない
- [ ] 設定ページ

### デザイン要件

- [x] カラーテーマ（アプリ全体の色合い）
  - **基本色**: シンプル・明るい（白または薄いグレー背景、白/グレー系のメインカラー）
  - **アクセントカラー**: ペールグリーン系（優しい感じの緑色）
    - HEX: `#C8E6C9` または `#D4EDDA`
    - TailwindCSS: `green-100` または `green-200`（ボタンやリンク、強調部分に使用）
  - **理由**: 色相環 UI を際立たせ、投稿写真が主役になる設計
- [x] アイコン・イラストの有無（MVP では最小限、必要最小限のアイコンのみ）
- [x] アニメーションの有無（最小限、色選択時のフィードバック程度）
- [x] ダークモード対応の有無（MVP では対応しない、将来実装）

### 色相環 UI 要件

#### 投稿時の色選択 UI

- [x] **表示形式**: 円形の色相環（12 色を円形に配置）
- [x] **インタラクション**: 自然な選択ができる UI（クリック/タップで選択）
- [x] **色選択時のフィードバック**: 選択中の色をハイライト表示（ボーダーや影で強調）
- [x] **色相環のサイズとレスポンシブ対応**: モバイルファースト、画面幅に応じてサイズ調整

#### カラーパレットの色相環 UI

- [x] **表示形式**: 円形の色相環（12 色を円形に配置、投稿時の色選択 UI と同じ形式）
- [x] **表示内容**: 全 12 色を表示、投稿した色のみ彩度がある（投稿していない色はグレーアウト）
- [x] **色のサイズ**: すべて同じサイズ
- [x] **色の並び順**: 色相環順（display_order 順）
- [x] **インタラクション**: クリック/タップでその色の投稿一覧を表示

---

## 非機能要件（要明確化）

### パフォーマンス

- [x] 画像の最適化（リサイズ、圧縮）
  - 最大幅 1080px に自動リサイズ
  - 自動圧縮あり
- [x] ページ読み込み速度の目標値（3 秒以内、モバイル）
- [x] 同時接続数の想定（MVP では想定不要、後から対応）

### セキュリティ

- [x] 画像アップロードのサイズ制限（10MB）
- [x] 画像の形式制限（JPEG, PNG, WebP）
- [x] 不正な画像の検出（NSFW 等）※MVP の段階では不要
- [x] 位置情報の暗号化 ※MVP の段階では不要

---

## 開発フェーズ

### Phase 1: MVP（最小機能）

1. ユーザー認証（Devise）
2. 色のお題機能
   - 今日のお題を表示（過去のお題は表示しない）
   - 12 色の色相環を初期データとして投入
   - 円形の色相環 UI で色を選択
   - オンデマンド生成で毎日のお題を自動生成（バッチジョブ不要）
     - ユーザーがトップページにアクセスした際に、今日のお題が存在しなければ自動生成
     - 過去 12 日間で使用された色を避けて、ランダムに 1 色を選択
     - すべての色が使用済みの場合は、全色から再選択（次のサイクル）
3. 投稿機能
   - 色相環から色を選択して投稿（必須、円形 UI で自然な選択）
   - 写真をアップロードして投稿（任意）
   - 写真なしでも投稿可能
   - 位置情報の記録（GPS 座標: Geolocation API で取得、またはテキスト入力「家」「カフェ」など、任意）
   - 説明文の追加（任意）
   - 記録した投稿は無制限で閲覧可能
4. カラーパレット表示（投稿した色の履歴を可視化）
   - 円形の色相環で全 12 色を表示
   - 投稿した色のみ彩度がある（投稿していない色はグレーアウト）
   - クリック/タップでその色の投稿一覧を表示

### Phase 2: 基本機能拡張

1. マップ表示機能（投稿の位置情報可視化）
   - Google Maps API を使用して投稿をマップ上に表示
   - カスタムマーカー（色相環の色を使用）
   - 情報ウィンドウで投稿写真と説明を表示
   - ナビゲーションにマップタブを追加
2. スタンプ・メダル機能
3. アルバム機能
4. 位置情報連携（AI レコメンド）
5. 天気連動機能

### Phase 3: 発展機能

1. ペアクエスト機能
2. AI レコメンド機能
3. ソーシャル機能（いいね、コメント、フォロー）

---

## 課題と対策

### 課題 1: 家から出るのが面倒で、身近にあるものでクリアしようとしてしまう

**対策**:

- 外出に限定しない（家の中でも OK）
- 位置情報と連携して「今日は〇〇駅でお出かけするとポイントアップ!」機能で外出を促進

### 課題 2: 継続的にユーザーが使ってもらえるか

**対策**:

- 想い出をどんどん投稿してもらう
- あとから見返す楽しさを提供（アルバム機能）
- 最初にいかに投稿をしてもらうかが肝

### 課題 3: 平日はあまり使わずに、休日だけになる

**対策**:

- 写真なしでも投稿可能なため、平日でも気軽に投稿できる

### 課題 4: 色に対する写真が似たようなもので単調になる

**対策**:

- 色のお題に「テーマ」を追加（例: 赤 →「夕焼け」「トマト」「赤い看板」など）
- ユーザー同士で投稿を見合える機能で多様性を促進
- AI レコメンドで新しいスポットを提案

---

## 要検討事項

### 優先度: 高

1. ~~**認証方式の決定**~~ - ✅ Devise に決定
2. ~~**色のお題の定義**~~ - ✅ DB のマスタテーブル（ColorTheme）で管理、12 色の色相環、ユーザーが色相環から選択
3. ~~**画像ストレージ**~~ - ✅ S3 に決定
4. ~~**位置情報 API**~~ - ✅ Google Maps API に決定
5. ~~**毎日のお題の自動生成**~~ - ✅ オンデマンド生成で実装（バッチジョブ不要）、過去 12 日間で色が被らないロジック、すべて出し切ったら次のサイクル
6. **天気 API** - OpenWeatherMap API vs Weather API（料金・機能比較）※MVP には含めない

### 優先度: 中

1. ~~**マップ表示機能**~~ - ✅ Phase 2 で実装予定、Google Maps API を使用、カスタムマーカーで色を識別
2. **ペア機能の実装方法** - 友達機能として実装するか、専用のペア機能とするか
3. **色の自動抽出** - Cloud Vision API vs 独自実装（コスト・精度）
4. **AI レコメンド** - 実装方法（ルールベース vs 機械学習）
5. **画像解析** - NSFW 検出の必要性

### 優先度: 低

1. **ソーシャル機能** - いいね、コメント、フォロー機能の有無
2. **通知機能** - プッシュ通知の有無
3. **共有機能** - SNS 共有機能の有無
4. **エクスポート機能** - データのエクスポート機能の有無

---

## 参考資料

### 色の定義

- **初期色データ**: [docs/initial_color_data.md](./initial_color_data.md) - 12 色の色相環の初期データ定義
- RGB 値と HEX コードの対応表
- 色名の日本語・英語対応表
- 色の心理的効果

### API ドキュメント

- Google Maps API: https://developers.google.com/maps
- Mapbox API: https://docs.mapbox.com/
- OpenWeatherMap API: https://openweathermap.org/api
- Weather API: https://www.weatherapi.com/

### デザインリソース

- カラーパレットのデザイン例
- スタンプ・メダルのデザイン例
- UI/UX の参考アプリ
