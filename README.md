# flutter_tokyo_map

東京の市区町村境界ポリゴン・鉄道駅・寺社仏閣を OpenStreetMap 上にインタラクティブに表示する Flutter アプリです。

---

## 概要

東京都の市区町村（23区・26市・町村）のポリゴン境界を地図に描画し、自治体を選択すると  
その地域内の**鉄道駅**または**寺社仏閣**をマーカーで重ね表示します。  
寺社はランク（S/A/B/C）でフィルタリングでき、参拝記録の可視化にも活用できます。

---

## 主な機能

- **市区町村ポリゴン表示**  
  東京都全域の行政区画境界を flutter_map の `PolygonLayer` で描画  
  選択した自治体は赤ハイライトし、その境界に合わせてカメラを自動フィット

- **カテゴリ切り替え**  
  画面上部のボタンで「23区」「26市」「町村」を切り替えて絞り込み表示

- **駅マーカー表示**  
  選択した自治体内に存在する駅を地図上にラベル付きマーカーで表示  
  同名駅は平均座標に統合して重複排除

- **寺社仏閣マーカー表示**  
  選択した自治体内の寺社を地図上にランク付きマーカーで表示  
  ランク（S / A / B / C）のフィルターボタンで絞り込み可能

- **ポリゴン内包判定**  
  Ray Casting アルゴリズム + モートン曲線（Z-Order）による描画順最適化

- **タイルキャッシュ**  
  `flutter_cache_manager` による OpenStreetMap タイルのローカルキャッシュ

---

## データモデル

```
TokyoMunicipalModel
  - name          : String                          // 自治体名
  - vertexCount   : int                             // 頂点数
  - minLat/maxLat : double                          // 緯度範囲
  - minLng/maxLng : double                          // 経度範囲
  - polygons      : List<List<List<List<double>>>>  // GeoJSON ポリゴン
  - centroidLat   : double                          // 重心緯度
  - centroidLng   : double                          // 重心経度

TokyoTrainModel
  - trainNumber : int
  - trainName   : String
  - station     : List<TokyoStationModel>

TokyoStationModel
  - id          : String
  - stationName : String
  - address     : String
  - lat / lng   : double

TempleModel
  - date           : String
  - startPoint     : String
  - endPoint       : String
  - templeDataList : List<TempleDataModel>

TempleDataModel
  - name      : String
  - address   : String
  - latitude  : String
  - longitude : String
  - rank      : String  // S / A / B / C
  - count     : int?
  - templePhotoModelList : List<TemplePhotoModel>?

TemplePhotoModel
  - date         : String
  - temple       : String
  - templephotos : List<String>
```

---

## 使用技術

| カテゴリ | ライブラリ |
|---|---|
| フレームワーク | Flutter / Dart |
| 状態管理 | [Riverpod](https://riverpod.dev/) (hooks_riverpod, riverpod_annotation) |
| HTTP 通信 | [http](https://pub.dev/packages/http) |
| 地図 | [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) |
| タイルキャッシュ | [flutter_cache_manager](https://pub.dev/packages/flutter_cache_manager), [cached_network_image](https://pub.dev/packages/cached_network_image) |
| チャート | [fl_chart](https://pub.dev/packages/fl_chart) |
| コード生成 | build_runner, freezed, json_serializable, riverpod_generator |
| その他 | font_awesome_flutter, scroll_to_index, dotted_line |

---

## データソース

| 用途 | ソース |
|---|---|
| 市区町村ポリゴン | ローカル JSON (`assets/json/`) |
| 鉄道駅データ | `http://toyohide.work/BrainLog/api/getTokyoTrainStation` |
| 寺社一覧 | `http://toyohide.work/BrainLog/api/getAllTemple` |
| 寺社緯度経度 | `http://toyohide.work/BrainLog/api/getTempleLatLng` |
| 寺社写真 | `http://toyohide.work/BrainLog/api/getTempleDatePhoto` |

---

## プロジェクト構成

```
lib/
├── controllers/
│   ├── _get_data/
│   │   ├── tokyo_municipal/  # 市区町村データ取得 (Riverpod Notifier)
│   │   ├── tokyo_train/      # 鉄道データ取得
│   │   └── temple/           # 寺社データ取得
│   ├── app_param/            # アプリ状態管理
│   └── controllers_mixin.dart
├── data/
│   └── http/                 # HTTP クライアント・API パス定義
├── extensions/               # Dart 拡張メソッド
├── models/                   # データモデル
├── screens/
│   ├── parts/                # カテゴリボタン等の共通 UI
│   └── home_screen.dart      # メイン画面（地図・ポリゴン・マーカー）
├── utility/                  # ユーティリティ
└── main.dart
assets/
├── images/                   # アイコン画像
└── json/                     # 市区町村ポリゴン JSON
```

---

## セットアップ

### 前提条件

- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`

### インストール

```bash
git clone https://github.com/toyotarou/flutter_tokyo_map.git
cd flutter_tokyo_map
flutter pub get
```

### コード生成

Riverpod プロバイダや Freezed クラスのコードを生成します。

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 実行

```bash
flutter run
```

---

## 対応プラットフォーム

- Android
- iOS
- macOS
- Windows
- Linux

---

## ライセンス

このプロジェクトにはライセンスファイルが設定されていません。
